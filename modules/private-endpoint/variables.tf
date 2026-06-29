variable "name" {
  description = "Private endpoint name"
  type        = string
}

variable "location" {
  description = "Azure region for the private endpoint"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID used for the private endpoint"
  type        = string
}

variable "private_connection_resource_id" {
  description = "Resource ID of the service behind the private endpoint"
  type        = string
}

variable "subresource_names" {
  description = "List of subresource names for the private service connection"
  type        = list(string)
}

variable "private_dns_zone_ids" {
  description = "Private DNS zone IDs to attach to the endpoint"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to associate with the private endpoint"
  type        = map(string)
  default     = {}
}