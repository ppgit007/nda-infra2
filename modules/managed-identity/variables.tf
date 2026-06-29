variable "name" {
  description = "Name of the Managed Identity"
  type        = string
}

variable "location" {
  description = "Azure region where the Managed Identity will be deployed"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "tags" {
  description = "Tags to associate with the Managed Identity"
  type        = map(string)
}