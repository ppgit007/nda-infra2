locals {

  deployment_flags = try(
    jsondecode(file("${path.root}/deployment-flags.json")),
    {}
  )

  module_enabled = {
    managed_identity  = lookup(local.deployment_flags, "managed_identity", true)
    key_vault         = lookup(local.deployment_flags, "key_vault", true)
    service_bus       = lookup(local.deployment_flags, "service_bus", true)
    static_web_app    = lookup(local.deployment_flags, "static_web_app", true)
    storage_accounts  = lookup(local.deployment_flags, "storage_accounts", true)
    app_service_plans = lookup(local.deployment_flags, "app_service_plans", true)
    function_apps     = lookup(local.deployment_flags, "function_apps", true)
    app_insights      = lookup(local.deployment_flags, "app_insights", true)
    log_analytics     = lookup(local.deployment_flags, "log_analytics", true)
    apim              = lookup(local.deployment_flags, "apim", true)
    private_endpoints = lookup(local.deployment_flags, "private_endpoints", true)
  }

  function_apps_enabled = local.module_enabled.function_apps && local.module_enabled.managed_identity && local.module_enabled.storage_accounts && local.module_enabled.app_service_plans

  abbreviations = jsondecode(
    file("${path.root}/../../shared/abbreviations.json")
  )
  # Common tags to be applied to all resources
  common_tags = {
    environment = var.environment
    owner       = var.owner
    project     = var.project
  }

  # Naming convention: subscription-project-environment-location-abbreviation
  # Example: vss-nda-dev-eus-mi (managed identity)
  name_prefix = "${var.subscription_shortcut}-${var.project_shortcut}-${var.environment}-${var.location_shortcut}"
  # Alphanumeric-only names for resources that don't support dashes (ACR, Storage Account)
  resource_name_alphanumeric = replace(local.name_prefix, "-", "")

  names = {
    static_web_app   = "${local.name_prefix}-${local.abbreviations.static_web_app}"
    key_vault        = "${local.name_prefix}-${local.abbreviations.key_vault}"
    managed_identity = "${local.name_prefix}-${local.abbreviations.managed_identity}"
    service_bus      = "${local.name_prefix}-${local.abbreviations.service_bus}"
    log_analytics    = "${local.resource_name_alphanumeric}-${local.abbreviations.log_analytics}"
  }

  private_dns_zones = merge(
    local.module_enabled.private_endpoints && local.module_enabled.storage_accounts ? {
      storage = "privatelink.blob.core.windows.net"
    } : {},
    local.module_enabled.private_endpoints && local.module_enabled.key_vault ? {
      key_vault = "privatelink.vaultcore.azure.net"
    } : {},
    local.module_enabled.private_endpoints && local.function_apps_enabled ? {
      function_app = "privatelink.azurewebsites.net"
    } : {}
  )

  storage_accounts = {
    data = substr("${local.resource_name_alphanumeric}${local.abbreviations.storage_account}data", 0, 24)
    fn   = substr("${local.resource_name_alphanumeric}${local.abbreviations.storage_account}fn", 0, 24)
    api  = substr("${local.resource_name_alphanumeric}${local.abbreviations.storage_account}api", 0, 24)
  }

  app_insights = {
    fn  = "${local.name_prefix}-${local.abbreviations.application_insights}-fn"
    api = "${local.name_prefix}-${local.abbreviations.application_insights}-api"
  }

  app_service_plans = {
    fn  = "${local.resource_name_alphanumeric}-${local.abbreviations.app_service_plan}-fn"
    api = "${local.resource_name_alphanumeric}-${local.abbreviations.app_service_plan}-api"
  }

  function_apps = {
    fn  = "${local.resource_name_alphanumeric}-${local.abbreviations.function_app}"
    api = "${local.resource_name_alphanumeric}-${local.abbreviations.function_app}-api"
  }

  function_app_deployments = {
    fn  = "deployment-fn"
    api = "deployment-api"
  }

  private_endpoint_definitions = local.module_enabled.private_endpoints ? merge(
    local.module_enabled.storage_accounts ? {
      for storage_key, storage_name in local.storage_accounts : "storage-${storage_key}" => {
        name              = "${storage_name}-pe"
        target_id         = module.storage_accounts[storage_key].id
        subresource_names = ["blob"]
        dns_zone_key      = "storage"
      }
    } : {},
    local.module_enabled.key_vault ? {
      key_vault = {
        name              = "${local.names.key_vault}-pe"
        target_id         = module.key_vault["enabled"].id
        subresource_names = ["vault"]
        dns_zone_key      = "key_vault"
      }
    } : {},
    local.function_apps_enabled ? {
      for function_key, function_name in local.function_apps : "function-${function_key}" => {
        name              = "${function_name}-pe"
        target_id         = module.function_apps[function_key].id
        subresource_names = ["sites"]
        dns_zone_key      = "function_app"
      }
    } : {}
  ) : {}


}