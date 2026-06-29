data "azurerm_resource_group" "target_rg" {
  name = var.resource_group_name
}

# The VNet and subnets are owned by the networking team and live in a separate RG.
# We consume them read-only — never manage or import them here.
data "azurerm_virtual_network" "existing" {
  name                = var.existing_vnet_name
  resource_group_name = var.existing_vnet_resource_group_name
}

# Subnet is created and delegated (Microsoft.App/environments) by the client's
# networking team. We consume it read-only — never manage or import it here.
data "azurerm_subnet" "function_apps" {
  name                 = var.function_subnet_name
  resource_group_name  = var.existing_vnet_resource_group_name
  virtual_network_name = data.azurerm_virtual_network.existing.name
}

data "azurerm_subnet" "private_endpoints" {
  name                 = var.private_endpoint_subnet_name
  resource_group_name  = var.existing_vnet_resource_group_name
  virtual_network_name = data.azurerm_virtual_network.existing.name
}

# Managed Identity
module "managed_identity" {
  for_each            = local.module_enabled.managed_identity ? { enabled = true } : {}
  source              = "../../modules/managed-identity"
  name                = local.names.managed_identity
  location            = var.location
  resource_group_name = data.azurerm_resource_group.target_rg.name
  tags                = local.common_tags
}

# Key Vault
module "key_vault" {
  for_each                        = local.module_enabled.key_vault ? { enabled = true } : {}
  source                          = "../../modules/key-vault"
  name                            = coalesce(var.key_vault_name, local.names.key_vault)
  location                        = var.location
  resource_group_name             = data.azurerm_resource_group.target_rg.name
  tenant_id                       = var.tenant_id
  monitor_diagnostic_workspace_id = try(module.log_analytics["enabled"].id, null)
  tags                            = local.common_tags
}

# Service Bus
module "service_bus" {
  for_each                        = local.module_enabled.service_bus ? { enabled = true } : {}
  source                          = "../../modules/service-bus"
  name                            = local.names.service_bus
  location                        = var.location
  resource_group_name             = data.azurerm_resource_group.target_rg.name
  monitor_diagnostic_workspace_id = try(module.log_analytics["enabled"].id, null)
  tags                            = local.common_tags
}

# Azure Container Registry (ACR)
# module "acr" {
#   source              = "../../modules/acr"
#   name                = "${local.resource_name_alphanumeric}${local.abbreviations.container_registry}"
#   location            = var.location
#   resource_group_name = data.azurerm_resource_group.target_rg.name
#   tags                = local.common_tags
# }

# # Container App Environment
# module "container_app_environment" {
#   source              = "../../modules/container-app-environment"
#   name                = "${local.name_prefix}-${local.abbreviations.container_app_environment}"
#   location            = var.location
#   resource_group_name = data.azurerm_resource_group.target_rg.name
#   tags                = local.common_tags
# }

# Container App
# module "container_app" {
#   source                       = "../../modules/container-app"
#   name                         = "${local.name_prefix}-${local.abbreviations.container_app}"
#   location                     = var.location
#   resource_group_name          = data.azurerm_resource_group.target_rg.name
#   container_app_environment_id = module.container_app_environment.id
#   image                        = var.container_app_image
#   tags                         = local.common_tags
#   identity_ids                 = [module.managed_identity.id]
# }

# Static Web App
module "static_web_app" {
  for_each             = local.module_enabled.static_web_app ? { enabled = true } : {}
  source               = "../../modules/static-web-app"
  name                 = local.names.static_web_app
  staticWebAppLocation = var.staticWebAppLocation
  resource_group_name  = data.azurerm_resource_group.target_rg.name
  tags                 = local.common_tags
}

# Storage Accounts (for_each pattern)
module "storage_accounts" {
  for_each                        = local.module_enabled.storage_accounts ? local.storage_accounts : {}
  source                          = "../../modules/storage-account"
  name                            = each.value
  location                        = var.location
  resource_group_name             = data.azurerm_resource_group.target_rg.name
  monitor_diagnostic_workspace_id = try(module.log_analytics["enabled"].id, null)
  tags                            = local.common_tags
}

resource "azurerm_role_assignment" "function_storage_blob" {
  for_each             = local.function_apps_enabled && var.create_function_storage_role_assignments ? local.function_apps : {}
  scope                = module.storage_accounts[each.key].id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = module.managed_identity["enabled"].principal_id
}

resource "azurerm_storage_container" "function_app" {
  for_each              = local.function_apps_enabled ? local.function_app_deployments : {}
  name                  = each.value
  storage_account_id    = module.storage_accounts[each.key].id
  container_access_type = "private"
}

# App Service Plan for Function App
# resource "azurerm_service_plan" "function_app_plan" {
#   name                = "${local.resource_name_alphanumeric}-${local.abbreviations.app_service_plan}"
#   location            = var.location
#   resource_group_name = data.azurerm_resource_group.target_rg.name
#   os_type             = "Windows"
#   sku_name            = "Y1" # <--- This single attribute replaces the entire nested sku {} block
# }

module "app_service_plans" {
  for_each = local.module_enabled.app_service_plans ? local.app_service_plans : {}
  source   = "../../modules/app-service-plan"

  name                = each.value
  location            = var.location
  resource_group_name = data.azurerm_resource_group.target_rg.name

  os_type  = var.os_type
  sku_name = each.key == "api" ? var.api_sku_name : var.sku_name

  tags = local.common_tags
}

# Function Apps (for_each pattern)
module "function_apps" {
  for_each                   = local.function_apps_enabled ? local.function_apps : {}
  source                     = "../../modules/function-app"
  name                       = each.value
  location                   = var.location
  resource_group_name        = data.azurerm_resource_group.target_rg.name
  app_service_plan_id        = module.app_service_plans[each.key].id
  virtual_network_subnet_id  = var.enable_function_vnet_integration ? data.azurerm_subnet.function_apps.id : null
  user_assigned_identity_id  = module.managed_identity["enabled"].id
  storage_container_endpoint = "${module.storage_accounts[each.key].primary_blob_endpoint}${azurerm_storage_container.function_app[each.key].name}"
  runtime_name               = "python"
  runtime_version            = "3.12"

  monitor_diagnostic_workspace_id = try(module.log_analytics["enabled"].id, null)
  tags                            = local.common_tags
}

# Application Insights (for_each pattern)
module "app_insights" {
  for_each            = local.module_enabled.app_insights ? local.app_insights : {}
  source              = "../../modules/app-insights"
  name                = each.value
  location            = var.location
  resource_group_name = data.azurerm_resource_group.target_rg.name
  workspace_id        = try(module.log_analytics["enabled"].id, null)
  tags                = local.common_tags
}

# Log Analytics
module "log_analytics" {
  for_each            = local.module_enabled.log_analytics ? { enabled = true } : {}
  source              = "../../modules/log-analytics"
  name                = local.names.log_analytics
  location            = var.location
  resource_group_name = data.azurerm_resource_group.target_rg.name
  tags                = local.common_tags
}

# Azure AI Search
# AI Search is provisioned outside this stack (pre-existing). No module here.

# Azure OpenAI
# Azure OpenAI is provisioned outside this stack (pre-existing). No module here.

resource "azurerm_private_dns_zone" "private_dns_zone" {
  for_each            = local.private_dns_zones
  name                = each.value
  resource_group_name = data.azurerm_resource_group.target_rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "private_dns_zone_link" {
  for_each              = local.private_dns_zones
  name                  = "${each.key}-vnet-link"
  resource_group_name   = data.azurerm_resource_group.target_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.private_dns_zone[each.key].name
  virtual_network_id    = data.azurerm_virtual_network.existing.id
}

module "private_endpoints" {
  for_each = local.private_endpoint_definitions
  source   = "../../modules/private-endpoint"

  name                           = each.value.name
  location                       = var.location
  resource_group_name            = data.azurerm_resource_group.target_rg.name
  subnet_id                      = data.azurerm_subnet.private_endpoints.id
  private_connection_resource_id = each.value.target_id
  subresource_names              = each.value.subresource_names
  private_dns_zone_ids           = [azurerm_private_dns_zone.private_dns_zone[each.value.dns_zone_key].id]
  tags                           = local.common_tags
}

# API Management (APIM)
# module "apim" {
#   source              = "../../modules/apim"
#   name                = local.resource_name
#   location            = var.location
#   resource_group_name = data.azurerm_resource_group.target_rg.name
#   publisher_name      = var.apim_publisher_name
#   publisher_email     = var.apim_publisher_email
#   sku_name            = var.apim_sku_name
#   sku_capacity        = var.apim_sku_capacity
#   tags                = local.common_tags
# }

# Role Assignment
#module "role_assignment" {
#  source               = "../../modules/role-assignment"
#  scope                = var.role_assignment_scope
#  role_definition_name = var.role_assignment_role_definition_name
#  principal_id         = module.managed_identity.principal_id
#}
#
## Grant ACR pull rights to the managed identity used by container apps
#resource "azurerm_role_assignment" "acr_pull" {
#  scope                = module.acr.id
#  role_definition_name = "AcrPull"
#  principal_id         = module.managed_identity.principal_id
#}
