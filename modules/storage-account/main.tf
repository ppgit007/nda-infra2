resource "azurerm_storage_account" "storage_account" {
  name                     = var.name
  location                 = var.location
  resource_group_name      = var.resource_group_name
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
  account_kind             = var.account_kind
  tags                     = var.tags

  # --- Hardening ---
  min_tls_version                   = var.min_tls_version
  https_traffic_only_enabled        = true
  public_network_access_enabled     = var.public_network_access_enabled
  shared_access_key_enabled         = var.shared_access_key_enabled
  allow_nested_items_to_be_public   = false
  infrastructure_encryption_enabled = var.infrastructure_encryption_enabled

  blob_properties {
    versioning_enabled = var.blob_versioning_enabled

    delete_retention_policy {
      days = var.blob_soft_delete_retention_days
    }

    container_delete_retention_policy {
      days = var.container_soft_delete_retention_days
    }
  }

  network_rules {
    default_action             = var.network_rules_default_action
    bypass                     = var.network_rules_bypass
    ip_rules                   = var.network_rules_ip_rules
    virtual_network_subnet_ids = var.network_rules_subnet_ids
  }
}

# Optional diagnostic settings -> Log Analytics. Created only when a workspace id
# is supplied. Categories are discovered dynamically to stay provider/version safe.
data "azurerm_monitor_diagnostic_categories" "storage_account" {
  count       = var.enable_diagnostics ? 1 : 0
  resource_id = azurerm_storage_account.storage_account.id
}

resource "azurerm_monitor_diagnostic_setting" "storage_account" {
  count                      = var.enable_diagnostics ? 1 : 0
  name                       = "diag-${var.name}"
  target_resource_id         = azurerm_storage_account.storage_account.id
  log_analytics_workspace_id = var.monitor_diagnostic_workspace_id

  dynamic "enabled_log" {
    for_each = data.azurerm_monitor_diagnostic_categories.storage_account[0].log_category_types
    content {
      category = enabled_log.value
    }
  }

  enabled_metric {
    category = "AllMetrics"
  }
}