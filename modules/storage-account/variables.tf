variable "name" {
  description = "Name of the Storage Account"
  type        = string
}

variable "location" {
  description = "Azure region where the Storage Account will be deployed"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "account_tier" {
  description = "Tier of the Storage Account"
  type        = string
  default     = "Standard"
}

variable "account_replication_type" {
  description = "Replication type of the Storage Account"
  type        = string
  default     = "LRS"
}

variable "account_kind" {
  description = "Kind of the Storage Account"
  type        = string
  default     = "StorageV2"
}

variable "tags" {
  description = "Tags to associate with the Storage Account"
  type        = map(string)
}

variable "min_tls_version" {
  description = "Minimum TLS version enforced on the Storage Account"
  type        = string
  default     = "TLS1_2"

  validation {
    condition     = contains(["TLS1_2"], var.min_tls_version)
    error_message = "min_tls_version must be TLS1_2 for production hardening."
  }
}

variable "public_network_access_enabled" {
  description = "Whether public network access to the Storage Account is enabled"
  type        = bool
  default     = false
}

variable "shared_access_key_enabled" {
  description = "Whether shared access keys (SAS/account keys) are allowed. Disabled to enforce Entra ID auth."
  type        = bool
  default     = false
}

variable "infrastructure_encryption_enabled" {
  description = "Whether infrastructure (double) encryption is enabled. Can only be set at creation."
  type        = bool
  default     = true
}

variable "blob_versioning_enabled" {
  description = "Whether blob versioning is enabled"
  type        = bool
  default     = true
}

variable "blob_soft_delete_retention_days" {
  description = "Number of days to retain soft-deleted blobs"
  type        = number
  default     = 7
}

variable "container_soft_delete_retention_days" {
  description = "Number of days to retain soft-deleted containers"
  type        = number
  default     = 7
}

variable "monitor_diagnostic_workspace_id" {
  description = "Log Analytics workspace ID for diagnostic settings. When null, no diagnostic setting is created."
  type        = string
  default     = null
}

variable "network_rules_default_action" {
  description = "Default action for the Storage Account network rules when no rule matches (Deny/Allow)"
  type        = string
  default     = "Deny"
}

variable "network_rules_bypass" {
  description = "Traffic that can bypass the network rules (e.g. AzureServices, Logging, Metrics)"
  type        = list(string)
  default     = ["AzureServices"]
}

variable "network_rules_ip_rules" {
  description = "List of public IP or CIDR ranges allowed to access the Storage Account"
  type        = list(string)
  default     = []
}

variable "network_rules_subnet_ids" {
  description = "List of subnet IDs allowed to access the Storage Account"
  type        = list(string)
  default     = []
}