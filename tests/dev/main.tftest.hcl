// Core resource and output tests for the dev environment.
// Plan-only: validates that key modules and outputs resolve correctly
// against the current for_each module structure.
// Location: tests/dev/main.tftest.hcl

run "validate_managed_identity" {
  command = plan

  assert {
    condition     = module.managed_identity["enabled"].id != null
    error_message = "Managed identity ID should be created."
  }

  assert {
    condition     = module.managed_identity["enabled"].principal_id != null
    error_message = "Managed identity principal_id should be created."
  }
}

run "validate_key_vault" {
  command = plan

  assert {
    condition     = module.key_vault["enabled"].id != null
    error_message = "Key Vault ID should be created."
  }

  assert {
    condition     = module.key_vault["enabled"].name != null
    error_message = "Key Vault name should be created."
  }
}

run "validate_storage_accounts" {
  command = plan

  assert {
    condition     = module.storage_accounts["data"].id != null
    error_message = "Data storage account should be created."
  }

  assert {
    condition     = module.storage_accounts["fn"].id != null
    error_message = "Function storage account should be created."
  }
}

run "validate_service_bus" {
  command = plan

  assert {
    condition     = module.service_bus["enabled"].id != null
    error_message = "Service Bus ID should be created."
  }
}

run "validate_static_web_app" {
  command = plan

  assert {
    condition     = module.static_web_app["enabled"].id != null
    error_message = "Static Web App ID should be created."
  }
}

run "validate_tagging" {
  command = plan

  assert {
    condition     = data.azurerm_resource_group.target_rg.tags != null
    error_message = "Target resource group should have tags available."
  }
}

run "validate_outputs_exist" {
  command = plan

  assert {
    condition     = output.resource_group_name != null
    error_message = "resource_group_name output should be defined."
  }

  assert {
    condition     = output.managed_identity_principal_id != null
    error_message = "managed_identity_principal_id output should be defined."
  }

  assert {
    condition     = output.key_vault_id != null
    error_message = "key_vault_id output should be defined."
  }

  assert {
    condition     = output.storage_account_id != null
    error_message = "storage_account_id output should be defined."
  }
}
