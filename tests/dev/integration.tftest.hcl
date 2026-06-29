// Module integration and output validation tests
// Ensures modules are properly integrated and outputs are correctly propagated
// Location: tests/dev/integration.tftest.hcl

run "module_outputs_managed_identity" {
  command = plan

  assert {
    condition     = can(module.managed_identity.id)
    error_message = "Managed identity ID should be available in the plan."
  }

  assert {
    condition     = can(module.managed_identity.principal_id)
    error_message = "Managed identity principal ID should be available in the plan."
  }
}

run "module_outputs_key_vault" {
  command = plan

  assert {
    condition     = output.key_vault_id == module.key_vault.id
    error_message = "Key Vault ID output should match module output."
  }

  assert {
    condition     = output.key_vault_uri == module.key_vault.vault_uri
    error_message = "Key Vault URI output should match module output."
  }
}

run "module_outputs_acr" {
  command = plan

  assert {
    condition     = can(module.acr.id)
    error_message = "ACR ID should be available in the plan."
  }

  assert {
    condition     = can(module.acr.login_server)
    error_message = "ACR login server should be available in the plan."
  }

  assert {
    condition     = can(module.acr.name)
    error_message = "ACR name should be available in the plan."
  }
}

run "module_outputs_redis" {
  command = plan

  assert {
    condition     = output.redis_id == module.redis.id
    error_message = "Redis ID output should match module output."
  }
}

run "module_outputs_storage_account" {
  command = plan

  assert {
    condition     = can(module.storage_account.id)
    error_message = "Storage Account ID should be available in the plan."
  }

  assert {
    condition     = can(module.storage_account.name)
    error_message = "Storage Account name should be available in the plan."
  }
}

run "module_outputs_container_app_environment" {
  command = plan

  assert {
    condition     = output.container_app_environment_id == module.container_app_environment.id
    error_message = "Container App Environment ID output should match module output."
  }
}

run "module_outputs_container_app" {
  command = plan

  assert {
    condition     = can(module.container_app.id)
    error_message = "Container App ID should be available in the plan."
  }

  assert {
    condition     = can(module.container_app.latest_revision_fqdn)
    error_message = "Container App FQDN should be available in the plan."
  }
}

run "module_outputs_static_web_app" {
  command = plan

  assert {
    condition     = output.static_web_app_id == module.static_web_app.id
    error_message = "Static Web App ID output should match module output."
  }

  assert {
    condition     = output.static_web_app_url == module.static_web_app.default_host_name
    error_message = "Static Web App URL output should match module output."
  }
}

run "module_outputs_service_bus" {
  command = plan

  assert {
    condition     = can(module.service_bus.id)
    error_message = "Service Bus ID should be available in the plan."
  }

  assert {
    condition     = can(module.service_bus.endpoint)
    error_message = "Service Bus endpoint should be available in the plan."
  }
}

run "module_integration_container_app_uses_environment" {
  command = plan

  assert {
    condition     = module.container_app.container_app_environment_id == module.container_app_environment.id
    error_message = "Container App should reference the correct Container App Environment."
  }
}

run "module_integration_container_app_uses_identity" {
  command = plan

  assert {
    condition     = contains(module.container_app.identity_ids, module.managed_identity.id)
    error_message = "Container App should use the managed identity for authentication."
  }
}

run "resource_group_reference" {
  command = plan

  assert {
    condition     = output.resource_group_name == data.azurerm_resource_group.target_rg.name
    error_message = "Resource group name output should match the data source."
  }
}

run "all_resources_in_same_rg" {
  command = plan

  assert {
    condition     = var.resource_group_name == data.azurerm_resource_group.target_rg.name
    error_message = "All resources should be deployed to the same resource group."
  }
}
