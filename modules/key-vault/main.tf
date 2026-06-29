resource "azurerm_key_vault" "key_vault" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = var.tenant_id
  sku_name            = var.sku_name
  tags                = var.tags

  # --- Hardening ---
  rbac_authorization_enabled    = var.enable_rbac_authorization
  purge_protection_enabled      = var.purge_protection_enabled
  soft_delete_retention_days    = var.soft_delete_retention_days
  public_network_access_enabled = var.public_network_access_enabled

  network_acls {
    default_action             = var.network_acls_default_action
    bypass                     = var.network_acls_bypass
    ip_rules                   = var.network_acls_ip_rules
    virtual_network_subnet_ids = var.network_acls_subnet_ids
  }
}

# Optional diagnostic settings -> Log Analytics. Created only when a workspace id
# is supplied. Categories are discovered dynamically to stay provider/version safe.
data "azurerm_monitor_diagnostic_categories" "key_vault" {
  count       = var.monitor_diagnostic_workspace_id != null ? 1 : 0
  resource_id = azurerm_key_vault.key_vault.id
}

resource "azurerm_monitor_diagnostic_setting" "key_vault" {
  count                      = var.monitor_diagnostic_workspace_id != null ? 1 : 0
  name                       = "diag-${var.name}"
  target_resource_id         = azurerm_key_vault.key_vault.id
  log_analytics_workspace_id = var.monitor_diagnostic_workspace_id

  dynamic "enabled_log" {
    for_each = data.azurerm_monitor_diagnostic_categories.key_vault[0].log_category_types
    content {
      category = enabled_log.value
    }
  }

  enabled_metric {
    category = "AllMetrics"
  }
}