// Variable validation and input tests
// Ensures all input variables are properly validated and have correct constraints
// Plan-only: no real resources are created.
// Location: tests/dev/input_validation.tftest.hcl

run "validate_location_not_empty" {
  command = plan

  assert {
    condition     = var.location != "" && var.location != null
    error_message = "Location variable must be provided and non-empty."
  }
}

run "validate_static_web_app_location_not_empty" {
  command = plan

  assert {
    condition     = var.staticWebAppLocation != "" && var.staticWebAppLocation != null
    error_message = "Static Web App location must be provided and non-empty."
  }
}

run "validate_resource_group_not_empty" {
  command = plan

  assert {
    condition     = var.resource_group_name != "" && var.resource_group_name != null
    error_message = "Workload resource group name must be provided and non-empty."
  }
}

run "validate_networking_resource_group_not_empty" {
  command = plan

  assert {
    condition     = var.existing_vnet_resource_group_name != "" && var.existing_vnet_resource_group_name != null
    error_message = "Networking (VNet) resource group name must be provided and non-empty."
  }
}

run "validate_tenant_id_format" {
  command = plan

  assert {
    condition     = can(regex("^[a-f0-9-]{36}$", var.tenant_id))
    error_message = "Tenant ID should be in UUID format."
  }
}

run "validate_static_web_app_name" {
  command = plan

  assert {
    condition     = length(var.static_web_app_name) > 0 && length(var.static_web_app_name) <= 60
    error_message = "Static Web App name must be between 1 and 60 characters."
  }
}

run "validate_os_type_valid_value" {
  command = plan

  assert {
    condition     = contains(["Windows", "Linux"], var.os_type)
    error_message = "OS type must be either 'Windows' or 'Linux'."
  }
}

run "validate_sku_name_not_empty" {
  command = plan

  assert {
    condition     = var.sku_name != "" && var.sku_name != null
    error_message = "SKU name cannot be empty."
  }
}

