resource "azurerm_servicebus_namespace" "service_bus" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku
  tags                = var.tags

  # --- Hardening ---
  local_auth_enabled            = var.local_auth_enabled
  minimum_tls_version           = var.minimum_tls_version
  public_network_access_enabled = var.public_network_access_enabled
}

# Optional diagnostic settings -> Log Analytics. Created only when a workspace id
# is supplied. Categories are discovered dynamically to stay provider/version safe.
data "azurerm_monitor_diagnostic_categories" "service_bus" {
  count       = var.enable_diagnostics ? 1 : 0
  resource_id = azurerm_servicebus_namespace.service_bus.id
}

resource "azurerm_monitor_diagnostic_setting" "service_bus" {
  count                      = var.enable_diagnostics ? 1 : 0
  name                       = "diag-${var.name}"
  target_resource_id         = azurerm_servicebus_namespace.service_bus.id
  log_analytics_workspace_id = var.monitor_diagnostic_workspace_id

  dynamic "enabled_log" {
    for_each = data.azurerm_monitor_diagnostic_categories.service_bus[0].log_category_types
    content {
      category = enabled_log.value
    }
  }

  enabled_metric {
    category = "AllMetrics"
  }
}