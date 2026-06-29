// Main test suite for dev environment Terraform configuration
// Tests core resource creation, variable validation, and output correctness
// Location: tests/dev/main.tftest.hcl

run "setup" {
  command = plan
}

run "validate_variables" {
  command = plan

  assert {
    condition     = var.location != null && var.location != ""
    error_message = "Location variable must be specified."
  }

  assert {
    condition     = var.resource_group_name != null && var.resource_group_name != ""
    error_message = "Resource group name must be specified."
  }

  assert {
    condition     = var.container_app_image != null && var.container_app_image != ""
    error_message = "Container app image must be specified."
  }

  assert {
    condition     = var.tenant_id != null && var.tenant_id != ""
    error_message = "Tenant ID must be specified."
  }
}

run "validate_managed_identity" {
  command = plan

  assert {
    condition     = module.managed_identity.id != null
    error_message = "Managed identity ID should be created."
  }

  assert {
    condition     = module.managed_identity.principal_id != null
    error_message = "Managed identity principal_id should be created."
  }
}

run "validate_key_vault" {
  command = plan

  assert {
    condition     = module.key_vault.id != null
    error_message = "Key Vault ID should be created."
  }

  assert {
    condition     = module.key_vault.name != null
    error_message = "Key Vault name should be created."
  }

  assert {
    condition     = module.key_vault.vault_uri != null
    error_message = "Key Vault URI should be created."
  }
}

run "validate_acr" {
  command = plan

  assert {
    condition     = module.acr.id != null
    error_message = "ACR ID should be created."
  }

  assert {
    condition     = module.acr.login_server != null
    error_message = "ACR login server should be created."
  }

  assert {
    condition     = module.acr.name != null
    error_message = "ACR name should be created."
  }
}

run "validate_redis" {
  command = plan

  assert {
    condition     = module.redis.id != null
    error_message = "Redis ID should be created."
  }
}

run "validate_storage_account" {
  command = plan

  assert {
    condition     = module.storage_account.id != null
    error_message = "Storage Account ID should be created."
  }

  assert {
    condition     = module.storage_account.name != null
    error_message = "Storage Account name should be created."
  }

  assert {
    condition     = module.storage_account.primary_access_key != null
    error_message = "Storage Account primary access key should be created."
  }
}

run "validate_container_app_environment" {
  command = plan

  assert {
    condition     = module.container_app_environment.id != null
    error_message = "Container App Environment ID should be created."
  }
}

run "validate_container_app" {
  command = plan

  assert {
    condition     = module.container_app.id != null
    error_message = "Container App ID should be created."
  }

  assert {
    condition     = module.container_app.latest_revision_fqdn != null
    error_message = "Container App FQDN should be created."
  }

  assert {
    condition     = module.container_app.custom_domain_verification_id != null || module.container_app.latest_revision_fqdn != null
    error_message = "Container App should have either custom domain or FQDN."
  }
}

run "validate_static_web_app" {
  command = plan

  assert {
    condition     = module.static_web_app.id != null
    error_message = "Static Web App ID should be created."
  }

  assert {
    condition     = module.static_web_app.default_host_name != null
    error_message = "Static Web App default hostname should be created."
  }
}

run "validate_service_bus" {
  command = plan

  assert {
    condition     = module.service_bus.id != null
    error_message = "Service Bus ID should be created."
  }
}

run "validate_tagging" {
  command = plan

  assert {
    condition     = data.azurerm_resource_group.target_rg.tags != null
    error_message = "Resource group should have tags applied."
  }
}

run "validate_outputs_exist" {
  command = plan

  assert {
    condition     = output.resource_group_name != null
    error_message = "Resource group name output should be defined."
  }

  assert {
    condition     = output.managed_identity_id != null
    error_message = "Managed identity ID output should be defined."
  }

  assert {
    condition     = output.key_vault_id != null
    error_message = "Key Vault ID output should be defined."
  }

  assert {
    condition     = output.acr_login_server != null
    error_message = "ACR login server output should be defined."
  }

  assert {
    condition     = output.container_app_fqdn != null
    error_message = "Container App FQDN output should be defined."
  }

  assert {
    condition     = output.storage_account_name != null
    error_message = "Storage account name output should be defined."
  }
}
