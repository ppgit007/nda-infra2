variable "name" {
  description = "Name of the App Service Plan"
  type        = string
}

variable "location" {
  description = "Azure region where the App Service Plan will be deployed"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "os_type" {
  description = "Type of the operating system (Linux/Windows). Flex Consumption requires Linux."
  type        = string
}

variable "sku_name" {
  description = "Name of the SKU. Use FC1 for a Flex Consumption plan."
  type        = string
}

variable "tags" {
  description = "Tags to associate with the App Service Plan"
  type        = map(string)
}
