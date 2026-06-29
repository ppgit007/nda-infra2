variable "name" {
  description = "Name of the Key Vault"
  type        = string
}

variable "location" {
  description = "Azure region where the Key Vault will be deployed"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "tenant_id" {
  description = "Azure Tenant ID"
  type        = string
}

variable "tags" {
  description = "Tags to associate with the Key Vault"
  type        = map(string)
}

variable "sku_name" {
  description = "SKU of the Key Vault (standard/premium)"
  type        = string
  default     = "standard"
}

variable "enable_rbac_authorization" {
  description = "Use Azure RBAC for data-plane authorization instead of access policies"
  type        = bool
  default     = true
}

variable "purge_protection_enabled" {
  description = "Enable purge protection to prevent permanent deletion during the retention period"
  type        = bool
  default     = true
}

variable "soft_delete_retention_days" {
  description = "Number of days deleted vaults/secrets are retained (7-90)"
  type        = number
  default     = 90

  validation {
    condition     = var.soft_delete_retention_days >= 7 && var.soft_delete_retention_days <= 90
    error_message = "soft_delete_retention_days must be between 7 and 90."
  }
}

variable "public_network_access_enabled" {
  description = "Whether public network access to the Key Vault is enabled"
  type        = bool
  default     = false
}

variable "monitor_diagnostic_workspace_id" {
  description = "Log Analytics workspace ID for diagnostic settings. When null, no diagnostic setting is created."
  type        = string
  default     = null
}

variable "network_acls_default_action" {
  description = "Default action for the Key Vault network ACL when no rule matches (Deny/Allow)"
  type        = string
  default     = "Deny"
}

variable "network_acls_bypass" {
  description = "Traffic that can bypass the network ACL (AzureServices/None)"
  type        = string
  default     = "AzureServices"
}

variable "network_acls_ip_rules" {
  description = "List of public IP or CIDR ranges allowed to access the Key Vault"
  type        = list(string)
  default     = []
}

variable "network_acls_subnet_ids" {
  description = "List of subnet IDs allowed to access the Key Vault"
  type        = list(string)
  default     = []
}