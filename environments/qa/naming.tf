variable "subscription_shortcut" {
  description = "Subscription shortcut code for resource naming (e.g., vss)"
  type        = string
}

variable "project" {
  description = "Project name to be used in resource naming"
  type        = string
}

variable "project_shortcut" {
  description = "Project shortcut code for resource naming (e.g., nda, nba)"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "location_shortcut" {
  description = "Location shortcut code for resource naming (e.g., eus for eastus, wus for westus)"
  type        = string
}

variable "component" {
  description = "Component name to be used in resource naming"
  type        = string
}