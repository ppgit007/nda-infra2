#resource "azurerm_linux_function_app" "function_app" {
#  name                       = var.name
#  location                   = var.location
#  resource_group_name        = var.resource_group_name
#  service_plan_id            = var.app_service_plan_id
#  storage_account_name       = var.storage_account_name
#  storage_account_access_key = var.storage_account_access_key
#  tags                       = var.tags
#
#  # site_config is intentionally omitted. For FlexConsumption plans the provider
#  # manages the function app config (FunctionAppConfig) automatically. Manually
#  # setting `linux_fx_version` causes a "Value for unconfigurable attribute" error.
#}

resource "azurerm_function_app_flex_consumption" "function_app" {
  name                      = var.name
  location                  = var.location
  resource_group_name       = var.resource_group_name
  service_plan_id           = var.app_service_plan_id
  virtual_network_subnet_id = var.virtual_network_subnet_id
  #vnet_route_all_enabled    = true

  # --- Hardening ---
  https_only                    = true
  public_network_access_enabled = var.public_network_access_enabled

  storage_container_type            = "blobContainer"
  storage_container_endpoint        = var.storage_container_endpoint
  storage_authentication_type       = "UserAssignedIdentity"
  storage_user_assigned_identity_id = var.user_assigned_identity_id

  identity {
    type         = "UserAssigned"
    identity_ids = [var.user_assigned_identity_id]
  }

  runtime_name           = var.runtime_name
  runtime_version        = var.runtime_version
  maximum_instance_count = 50
  instance_memory_in_mb  = 2048

  site_config {}

  tags = var.tags
}

# Optional diagnostic settings -> Log Analytics. Created only when a workspace id
# is supplied. Categories are discovered dynamically to stay provider/version safe.
data "azurerm_monitor_diagnostic_categories" "function_app" {
  count       = var.enable_diagnostics ? 1 : 0
  resource_id = azurerm_function_app_flex_consumption.function_app.id
}

resource "azurerm_monitor_diagnostic_setting" "function_app" {
  count                      = var.enable_diagnostics ? 1 : 0
  name                       = "diag-${var.name}"
  target_resource_id         = azurerm_function_app_flex_consumption.function_app.id
  log_analytics_workspace_id = var.monitor_diagnostic_workspace_id

  dynamic "enabled_log" {
    for_each = data.azurerm_monitor_diagnostic_categories.function_app[0].log_category_types
    content {
      category = enabled_log.value
    }
  }

  enabled_metric {
    category = "AllMetrics"
  }
}