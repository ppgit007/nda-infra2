variable "name" {
  description = "Name of the API Management instance"
  type        = string
}

variable "location" {
  description = "Azure region where the API Management instance will be deployed"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "publisher_name" {
  description = "Name of the API Management publisher"
  type        = string
}

variable "publisher_email" {
  description = "Email of the API Management publisher"
  type        = string
}

variable "sku_name" {
  description = "SKU of the API Management instance"
  type        = string
  default     = "Developer" # Default to Developer SKU
}

variable "sku_capacity" {
  description = "Capacity of the API Management SKU"
  type        = number
  default     = 1 # Default to 1 capacity unit
}

variable "tags" {
  description = "Tags to associate with the API Management instance"
  type        = map(string)
}