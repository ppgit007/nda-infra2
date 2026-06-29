output "id" {
  description = "The ID of the API Management instance"
  value       = azurerm_api_management.apim.id
}

output "gateway_url" {
  description = "The Gateway URL of the API Management instance"
  value       = azurerm_api_management.apim.gateway_url
}