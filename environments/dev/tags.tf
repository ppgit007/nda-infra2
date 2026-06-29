variable "owner" {
  description = "Owner of the resources"
  type        = string
}

variable "additional_tags" {
  description = "Additional tags to be added to the resources"
  type        = map(string)
  default     = {}
}

output "tags" {
  value = merge(local.common_tags, var.additional_tags)
}