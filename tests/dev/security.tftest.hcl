// Security-policy unit tests (module-in-isolation, plan-only).
//
// Unlike the root-config tests, each run here points at a single module via a
// `module {}` block and asserts directly on the planned resource attributes.
// This is what `terraform plan` cannot do: it proves our hardening posture
// (no keys, no public access, TLS floor, identity-based auth) has not regressed.
//
// These runs fire no data sources (enable_diagnostics defaults to false), so
// they need NO Azure credentials and create NO resources.
// Location: tests/dev/security.tftest.hcl

# Module-under-test runs do not inherit the root provider, so configure one here.
# No credentials are exercised: plan of create-only resources makes no API calls.
provider "azurerm" {
  features {}
  resource_provider_registrations = "none"
}

# --- Storage Account hardening -------------------------------------------------
run "storage_account_hardening" {
  command = plan

  module {
    source = "../../modules/storage-account"
  }

  variables {
    name                = "vssndadeveussatest"
    location            = "eastus"
    resource_group_name = "my-rg2"
    tags                = { env = "test" }
  }

  assert {
    condition     = azurerm_storage_account.storage_account.shared_access_key_enabled == false
    error_message = "Storage account must disable shared access keys (Entra ID auth only)."
  }

  assert {
    condition     = azurerm_storage_account.storage_account.public_network_access_enabled == false
    error_message = "Storage account must not allow public network access."
  }

  assert {
    condition     = azurerm_storage_account.storage_account.min_tls_version == "TLS1_2"
    error_message = "Storage account must enforce a TLS1_2 minimum."
  }

  assert {
    condition     = azurerm_storage_account.storage_account.https_traffic_only_enabled == true
    error_message = "Storage account must require HTTPS-only traffic."
  }

  assert {
    condition     = azurerm_storage_account.storage_account.allow_nested_items_to_be_public == false
    error_message = "Storage account must block public blob/container access."
  }

  assert {
    condition     = azurerm_storage_account.storage_account.network_rules[0].default_action == "Deny"
    error_message = "Storage account network rules must default-deny."
  }
}

# --- Key Vault hardening -------------------------------------------------------
run "key_vault_hardening" {
  command = plan

  module {
    source = "../../modules/key-vault"
  }

  variables {
    name                = "vss-nda-dev-eus-kvt"
    location            = "eastus"
    resource_group_name = "my-rg2"
    tenant_id           = "00000000-0000-0000-0000-000000000000"
    tags                = { env = "test" }
  }

  assert {
    condition     = azurerm_key_vault.key_vault.rbac_authorization_enabled == true
    error_message = "Key Vault must use Azure RBAC for data-plane authorization."
  }

  assert {
    condition     = azurerm_key_vault.key_vault.purge_protection_enabled == true
    error_message = "Key Vault must enable purge protection."
  }

  assert {
    condition     = azurerm_key_vault.key_vault.public_network_access_enabled == false
    error_message = "Key Vault must not allow public network access."
  }

  assert {
    condition     = azurerm_key_vault.key_vault.soft_delete_retention_days == 90
    error_message = "Key Vault must retain soft-deleted items for 90 days."
  }

  assert {
    condition     = azurerm_key_vault.key_vault.network_acls[0].default_action == "Deny"
    error_message = "Key Vault network ACLs must default-deny."
  }
}

# --- Service Bus hardening -----------------------------------------------------
run "service_bus_hardening" {
  command = plan

  module {
    source = "../../modules/service-bus"
  }

  variables {
    name                = "vss-nda-dev-eus-sbt"
    location            = "eastus"
    resource_group_name = "my-rg2"
    tags                = { env = "test" }
  }

  assert {
    condition     = azurerm_servicebus_namespace.service_bus.local_auth_enabled == false
    error_message = "Service Bus must disable local (SAS) auth in favour of Entra ID."
  }

  assert {
    condition     = azurerm_servicebus_namespace.service_bus.minimum_tls_version == "1.2"
    error_message = "Service Bus must enforce a TLS 1.2 minimum."
  }
}

# --- Function App hardening ----------------------------------------------------
run "function_app_hardening" {
  command = plan

  module {
    source = "../../modules/function-app"
  }

  variables {
    name                       = "vss-nda-dev-eus-fnt"
    location                   = "eastus"
    resource_group_name        = "my-rg2"
    app_service_plan_id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/my-rg2/providers/Microsoft.Web/serverFarms/test-plan"
    user_assigned_identity_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/my-rg2/providers/Microsoft.ManagedIdentity/userAssignedIdentities/test-mi"
    storage_container_endpoint = "https://vssndadeveussatest.blob.core.windows.net/app-package"
    runtime_name               = "python"
    runtime_version            = "3.12"
    tags                       = { env = "test" }
  }

  assert {
    condition     = azurerm_function_app_flex_consumption.function_app.https_only == true
    error_message = "Function App must require HTTPS-only traffic."
  }

  assert {
    condition     = azurerm_function_app_flex_consumption.function_app.public_network_access_enabled == false
    error_message = "Function App must not allow public network access."
  }

  assert {
    condition     = azurerm_function_app_flex_consumption.function_app.storage_authentication_type == "UserAssignedIdentity"
    error_message = "Function App storage must authenticate via managed identity, not keys."
  }

  assert {
    condition     = azurerm_function_app_flex_consumption.function_app.identity[0].type == "UserAssigned"
    error_message = "Function App must run under a user-assigned managed identity."
  }
}

