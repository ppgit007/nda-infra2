variable "name" {
  description = "Name of the Log Analytics Workspace"
  type        = string
}

variable "location" {
  description = "Azure region where the Log Analytics Workspace will be deployed"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "sku" {
  description = "SKU of the Log Analytics Workspace"
  type        = string
  default     = "PerGB2018"
}

variable "retention_in_days" {
  description = "Retention period for the logs in days"
  type        = number
  default     = 30
}

variable "internet_ingestion_enabled" {
  description = "Whether log ingestion over the public internet is allowed"
  type        = bool
  default     = true
}

variable "internet_query_enabled" {
  description = "Whether querying over the public internet is allowed"
  type        = bool
  default     = true
}

variable "daily_quota_gb" {
  description = "Daily ingestion cap in GB (-1 for unlimited)"
  type        = number
  default     = -1
}

variable "tags" {
  description = "Tags to associate with the Log Analytics Workspace"
  type        = map(string)
}