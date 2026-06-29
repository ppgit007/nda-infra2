terraform {
  backend "azurerm" {
    resource_group_name  = "rg-qa-terraform-mgmt"
    storage_account_name = "stqatfstate2026"
    container_name       = "tfstate"
    key                  = "qa.terraform.tfstate"
    use_azuread_auth     = true
  }
}