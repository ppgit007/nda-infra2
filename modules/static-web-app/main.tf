#resource "azurerm_static_site" "static_web_app" {
#  name                = var.name
#  location            = var.staticWebAppLocation
#  resource_group_name = var.resource_group_name
#  sku_tier            = "Free"
#  tags                = var.tags
#  
#  # Minimal site_config block: required by provider for creation.
#  # Add app_location/api_location/custom_build_command as needed.
#  site_config {}
#}


resource "azurerm_static_web_app" "static_web_app" {
  name                = var.name
  location            = var.staticWebAppLocation
  resource_group_name = var.resource_group_name
  sku_tier            = "Free"
  sku_size            = "Free"
  tags                = var.tags
}