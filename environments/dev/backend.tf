terraform {
  backend "azurerm" {
    resource_group_name  = "rg-dev-terraform-mgmt"
    storage_account_name = "stdevtfstate2026"
    container_name       = "tfstate"
    key                  = "dev.terraform.tfstate"
    use_azuread_auth     = true
  }
}