variable "name" {
  description = "Name of the Function App"
  type        = string
}

variable "location" {
  description = "Azure region where the Function App will be deployed"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "app_service_plan_id" {
  description = "ID of the App Service Plan"
  type        = string
}

variable "virtual_network_subnet_id" {
  description = "Subnet ID for regional VNet integration"
  type        = string
  default     = null
  nullable    = true
}

variable "user_assigned_identity_id" {
  description = "User-assigned managed identity ID for storage auth"
  type        = string
}

variable "storage_container_endpoint" {
  description = "Blob container endpoint used by the Function App"
  type        = string
}

variable "runtime_name" {
  description = "Function App runtime name"
  type        = string
}

variable "runtime_version" {
  description = "Function App runtime version"
  type        = string
}

variable "tags" {
  description = "Tags to associate with the Function App"
  type        = map(string)
}

variable "public_network_access_enabled" {
  description = "Whether public network access to the Function App is enabled"
  type        = bool
  default     = false
}

variable "monitor_diagnostic_workspace_id" {
  description = "Log Analytics workspace ID for diagnostic settings. When null, no diagnostic setting is created."
  type        = string
  default     = null
}