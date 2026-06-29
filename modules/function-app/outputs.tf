output "id" {
  value = azurerm_function_app_flex_consumption.function_app.id
}

output "url" {
  value = azurerm_function_app_flex_consumption.function_app.default_hostname
}