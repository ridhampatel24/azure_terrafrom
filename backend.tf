terraform {
  backend "azurerm" {
    resource_group_name  = "Storage"
    storage_account_name = "ridham"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}
