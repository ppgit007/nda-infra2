variable "name" {
  description = "Name of the Application Insights resource"
  type        = string
}

variable "location" {
  description = "Azure region where the Application Insights will be deployed"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "application_type" {
  description = "Type of application for Application Insights"
  type        = string
  default     = "web"
}

variable "workspace_id" {
  description = "Log Analytics workspace ID to back this workspace-based Application Insights. Classic mode is used when null."
  type        = string
  default     = null
}

variable "retention_in_days" {
  description = "Data retention period in days"
  type        = number
  default     = 90
}

variable "internet_ingestion_enabled" {
  description = "Whether telemetry ingestion over the public internet is allowed"
  type        = bool
  default     = true
}

variable "internet_query_enabled" {
  description = "Whether querying over the public internet is allowed"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to associate with the Application Insights resource"
  type        = map(string)
}