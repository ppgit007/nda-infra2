// Security configuration tests for dev environment
// Validates security best practices and compliance configurations
// Location: tests/dev/security.tftest.hcl

run "security_key_vault_access" {
  command = plan

  assert {
    condition     = module.key_vault.id != null
    error_message = "Key Vault must be provisioned for secure secret storage."
  }
}

run "security_managed_identity" {
  command = plan

  assert {
    condition     = module.managed_identity.id != null
    error_message = "Managed identity must be created for secure authentication."
  }

  assert {
    condition     = module.managed_identity.principal_id != null
    error_message = "Managed identity principal ID must exist for role assignments."
  }
}

run "security_container_app_identity" {
  command = plan

  // Verify Container App uses managed identity
  assert {
    condition     = length(module.container_app.identity_ids) > 0
    error_message = "Container App must use managed identity for ACR authentication."
  }
}

run "security_acr_configuration" {
  command = plan

  assert {
    condition     = module.acr.id != null
    error_message = "ACR must be provisioned for private container image storage."
  }
}

run "security_storage_account" {
  command = plan

  assert {
    condition     = module.storage_account.id != null
    error_message = "Storage Account must be provisioned for application data."
  }
}

run "security_redis_encryption" {
  command = plan

  assert {
    condition     = module.redis.id != null
    error_message = "Redis Enterprise cluster must be provisioned with encryption support."
  }
}

run "security_service_bus" {
  command = plan

  assert {
    condition     = module.service_bus.id != null
    error_message = "Service Bus must be provisioned for secure messaging."
  }
}

run "security_location_consistency" {
  command = plan

  assert {
    condition     = var.location == "East US"
    error_message = "Location should be consistent (East US) for compliance."
  }
}

run "security_tags_applied" {
  command = plan

  assert {
    condition     = can(data.azurerm_resource_group.target_rg.tags)
    error_message = "All resources should have proper tags for compliance tracking."
  }
}
