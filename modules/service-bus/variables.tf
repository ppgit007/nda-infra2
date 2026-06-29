variable "name" {
  description = "Name of the Service Bus Namespace"
  type        = string
}

variable "location" {
  description = "Azure region where the Service Bus Namespace will be deployed"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "sku" {
  description = "SKU of the Service Bus Namespace"
  type        = string
  default     = "Standard"
}

variable "tags" {
  description = "Tags to associate with the Service Bus Namespace"
  type        = map(string)
}

variable "local_auth_enabled" {
  description = "Whether SAS (local) authentication is allowed. Disabled to enforce Entra ID auth."
  type        = bool
  default     = false
}

variable "minimum_tls_version" {
  description = "Minimum TLS version enforced on the Service Bus Namespace"
  type        = string
  default     = "1.2"
}

variable "public_network_access_enabled" {
  description = "Whether public network access is enabled. Network restriction via private endpoint requires the Premium SKU."
  type        = bool
  default     = true
}

variable "enable_diagnostics" {
  description = "Whether to create diagnostic settings. Known at plan time; gates the diagnostic count."
  type        = bool
  default     = false
}

variable "monitor_diagnostic_workspace_id" {
  description = "Log Analytics workspace ID for diagnostic settings. When null, no diagnostic setting is created."
  type        = string
  default     = null
}