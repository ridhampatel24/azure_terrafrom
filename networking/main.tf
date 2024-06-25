variable "vnet_name" {}
variable "vnet_cidr" {}
variable "vnet_location" {}
variable "res_grp_name" {}
variable "cidr_public_subnet" {}

resource "azurerm_virtual_network" "ridham_vnet" {
  name                = var.vnet_name
  address_space       = var.vnet_cidr
  location            = var.vnet_location
  resource_group_name = var.res_grp_name
}

# resource "azurerm_subnet" "ridham_subnet" {
#   name                 = "internal"
#   resource_group_name  = var.res_grp_name
#   virtual_network_name = var.vnet_name
#   address_prefixes     = var.cidr_public_subnet
# }
