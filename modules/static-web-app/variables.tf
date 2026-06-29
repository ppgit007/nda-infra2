variable "name" {
  description = "Name of the Static Web App"
  type        = string
}

variable "staticWebAppLocation" {
  description = "Azure region where the Static Web App will be deployed"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "tags" {
  description = "Tags to associate with the Static Web App"
  type        = map(string)
}