variable "location" {
  description = "Azure region where resources will be deployed"
  type        = string
  default     = "East US"
}

variable "staticWebAppLocation" {
  description = "Azure region where the Static Web App will be deployed"
  type        = string
  default     = "East US 2"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "my-rg1"
}

variable "existing_vnet_name" {
  description = "Name of the pre-existing virtual network"
  type        = string
  default     = "vss-nda-dev-eus-vnet"
}

variable "function_subnet_name" {
  description = "Name of the subnet used for function app VNet integration"
  type        = string
  default     = "vss-nba-dev-eus-snet-func"
}

variable "private_endpoint_subnet_name" {
  description = "Name of the subnet used for private endpoints"
  type        = string
  default     = "vss-nba-dev-eus-snet-pep"
}

variable "tenant_id" {
  description = "Azure Tenant ID for Key Vault"
  type        = string
}

# variable "container_app_image" {
#   description = "Container image for the Container App"
#   type        = string
# }

# variable "function_app_service_plan_id" {
#   description = "Service Plan ID for the Function App"
#   type        = string
# }

# variable "function_app_storage_account_name" {
#   description = "Storage Account Name for the Function App"
#   type        = string
# }

# variable "function_app_storage_account_access_key" {
#   description = "Storage Account Access Key for the Function App"
#   type        = string
# }

# variable "apim_publisher_name" {
#   description = "Publisher name for API Management"
#   type        = string
# }

# variable "apim_publisher_email" {
#   description = "Publisher email for API Management"
#   type        = string
# }

# variable "apim_sku_name" {
#   description = "SKU of the API Management instance"
#   type        = string
#   default     = "Developer"
# }

# variable "apim_sku_capacity" {
#   description = "Capacity of the API Management SKU"
#   type        = number
#   default     = 1
# }

#variable "role_assignment_scope" {
#  description = "Scope for the Role Assignment"
#  type        = string
#}
#
#variable "role_assignment_role_definition_name" {
#  description = "Role definition name for the Role Assignment"
#  type        = string
#}

variable "static_web_app_name" {
  description = "Name of the Static Web App"
  type        = string
}

# variable "container_app_name" {
#   description = "Name of the Container App"
#   type        = string
# }

variable "os_type" {
  description = "OS type for the Function App"
  type        = string
}

variable "sku_name" {
  description = "SKU name for the Function App"
  type        = string
}

variable "api_sku_name" {
  description = "SKU name for the API Function App plan"
  type        = string
  default     = "FC1"
}

variable "ai_search_sku" {
  description = "SKU for Azure AI Search"
  type        = string
  default     = "basic"
}

variable "ai_search_replica_count" {
  description = "Replica count for Azure AI Search"
  type        = number
  default     = 1
}

variable "ai_search_partition_count" {
  description = "Partition count for Azure AI Search"
  type        = number
  default     = 1
}

variable "openai_location" {
  description = "Azure region for Azure OpenAI"
  type        = string
  default     = "eastus2"
}

variable "openai_sku_name" {
  description = "SKU name for Azure OpenAI account"
  type        = string
  default     = "S0"
}

variable "openai_deployments" {
  description = "Optional Azure OpenAI model deployments"
  type = list(object({
    name          = string
    model_name    = string
    model_version = string
    sku_name      = optional(string, "GlobalStandard")
    sku_capacity  = optional(number, 10)
  }))
  default = []
}

# variable "function_app_name" {
#   description = "Name of the Function App"
#   type        = string
# }

variable "key_vault_name" {
  description = "Optional Key Vault name override. When null, the convention-based local name is used."
  type        = string
  default     = null
  nullable    = true
}

variable "enable_function_vnet_integration" {
  description = "Whether to enable regional VNet integration for Function Apps"
  type        = bool
  default     = false
}

variable "create_function_storage_role_assignments" {
  description = "Whether Terraform should create Storage Blob Data Contributor role assignments for Function Apps"
  type        = bool
  default     = false
}