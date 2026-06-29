output "resource_group_name" {
  value = data.azurerm_resource_group.target_rg.name
}

output "managed_identity_principal_id" {
  value = module.managed_identity["enabled"].principal_id
}

output "key_vault_id" {
  value = module.key_vault["enabled"].id
}

output "service_bus_id" {
  value = try(module.service_bus["enabled"].id, null)
}

# output "acr_login_server" {
#   value = module.acr.login_server
# }

# output "container_app_environment_id" {
#   value = module.container_app_environment.id
# }

# output "container_app_url" {
#   value = module.container_app.url
# }

output "static_web_app_url" {
  value = try(module.static_web_app["enabled"].url, null)
}

output "function_app_url" {
  value = module.function_apps["fn"].url
}

output "api_function_app_url" {
  value = module.function_apps["api"].url
}

output "storage_account_id" {
  value = module.storage_accounts["data"].id
}

output "storage_account_ids" {
  value = {
    for k, sa in module.storage_accounts : k => sa.id
  }
}

output "app_insights_instrumentation_key" {
  value     = try(module.app_insights["fn"].instrumentation_key, null)
  sensitive = true
}

output "app_insights_instrumentation_keys" {
  value = try({
    for k, ai in module.app_insights : k => ai.instrumentation_key
  }, {})
  sensitive = true
}

output "app_insights_ids" {
  value = try({
    for k, ai in module.app_insights : k => ai.id
  }, {})
}

output "app_service_plan_ids" {
  value = {
    for k, plan in module.app_service_plans : k => plan.id
  }
}

output "log_analytics_id" {
  value = try(module.log_analytics["enabled"].id, null)
}

output "private_endpoint_definitions_planned" {
  description = "Private endpoint keys and names Terraform planned from locals"
  value = {
    for k, pe in local.private_endpoint_definitions : k => pe.name
  }
}

output "private_endpoint_ids_created" {
  description = "Private endpoint IDs successfully created"
  value = {
    for k, pe in module.private_endpoints : k => pe.id
  }
}

# output "apim_gateway_url" {
#   value = module.apim.gateway_url
# }

# output "role_assignment_id" {
#   value = module.role_assignment.id
# }