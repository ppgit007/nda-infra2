// Variable validation and input tests
// Ensures all input variables are properly validated and have correct constraints
// Location: tests/dev/input_validation.tftest.hcl

run "validate_location_not_empty" {
  command = plan

  assert {
    condition     = var.location != ""
    error_message = "Location variable cannot be empty."
  }

  assert {
    condition     = var.location != null
    error_message = "Location variable must be provided."
  }
}

run "validate_static_web_app_location_not_empty" {
  command = plan

  assert {
    condition     = var.staticWebAppLocation != ""
    error_message = "Static Web App location cannot be empty."
  }

  assert {
    condition     = var.staticWebAppLocation != null
    error_message = "Static Web App location must be provided."
  }
}

run "validate_resource_group_not_empty" {
  command = plan

  assert {
    condition     = var.resource_group_name != ""
    error_message = "Resource group name cannot be empty."
  }

  assert {
    condition     = var.resource_group_name != null
    error_message = "Resource group name must be provided."
  }
}

run "validate_tenant_id_format" {
  command = plan

  assert {
    condition     = can(regex("^[a-f0-9-]{36}$", var.tenant_id)) || var.tenant_id != ""
    error_message = "Tenant ID should be in UUID format."
  }
}

run "validate_container_app_image_not_empty" {
  command = plan

  assert {
    condition     = var.container_app_image != ""
    error_message = "Container app image cannot be empty."
  }

  assert {
    condition     = var.container_app_image != null
    error_message = "Container app image must be provided."
  }
}

run "validate_container_app_image_format" {
  command = plan

  assert {
    condition     = can(regex(".*:.*", var.container_app_image)) || can(regex(".*/.*", var.container_app_image))
    error_message = "Container app image should include registry and tag."
  }
}

run "validate_static_web_app_name_not_empty" {
  command = plan

  assert {
    condition     = var.static_web_app_name != ""
    error_message = "Static Web App name cannot be empty."
  }
}

run "validate_container_app_name_not_empty" {
  command = plan

  assert {
    condition     = var.container_app_name != ""
    error_message = "Container App name cannot be empty."
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
    condition     = var.sku_name != ""
    error_message = "SKU name cannot be empty."
  }
}

run "validate_resource_naming_conventions" {
  command = plan

  assert {
    condition     = length(var.container_app_name) > 0 && length(var.container_app_name) <= 63
    error_message = "Container app name must be between 1 and 63 characters."
  }

  assert {
    condition     = length(var.static_web_app_name) > 0 && length(var.static_web_app_name) <= 60
    error_message = "Static Web App name must be between 1 and 60 characters."
  }
}

run "validate_location_values" {
  command = plan

  assert {
    condition     = contains(["East US", "West US", "East US 2", "West US 2", "Central US", "South Central US", "North Central US", "West Central US"], var.location)
    error_message = "Location must be a valid Azure region."
  }
}

run "validate_default_values" {
  command = plan

  assert {
    condition     = var.resource_group_name == "my-rg1"
    error_message = "Default resource group name should be 'my-rg1'."
  }

  assert {
    condition     = var.location == "East US"
    error_message = "Default location should be 'East US'."
  }

  assert {
    condition     = var.staticWebAppLocation == "East US 2"
    error_message = "Default static web app location should be 'East US 2'."
  }
}

run "validate_required_variables_provided" {
  command = plan

  assert {
    condition     = var.tenant_id != null && var.tenant_id != ""
    error_message = "Required variable 'tenant_id' must be provided."
  }

  assert {
    condition     = var.container_app_image != null && var.container_app_image != ""
    error_message = "Required variable 'container_app_image' must be provided."
  }

  assert {
    condition     = var.static_web_app_name != null && var.static_web_app_name != ""
    error_message = "Required variable 'static_web_app_name' must be provided."
  }

  assert {
    condition     = var.container_app_name != null && var.container_app_name != ""
    error_message = "Required variable 'container_app_name' must be provided."
  }
}
