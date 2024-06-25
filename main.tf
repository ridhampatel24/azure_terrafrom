resource "azurerm_resource_group" "ridham_res" {
  name     = var.resource_grp_name
  location = var.resource_grp_location
}


module "networking" {
  source             = "./networking"
  vnet_cidr          = var.vnet_cidr
  vnet_name          = var.vnet_name
  vnet_location      = azurerm_resource_group.ridham_res.location
  res_grp_name       = azurerm_resource_group.ridham_res.name
  cidr_public_subnet = var.cidr_public_subnet
}


# resource "azurerm_virtual_network" "ridham_vnet" {
#   name                = var.vnet_name
#   address_space       = ["10.0.0.0/16"] 
#   location            = azurerm_resource_group.ridham_res.location
#   resource_group_name = azurerm_resource_group.ridham_res.name
# }

resource "azurerm_subnet" "ridham_subnet" {
  name                 = "internal"
  depends_on           = [module.networking]
  resource_group_name  = azurerm_resource_group.ridham_res.name
  virtual_network_name = var.vnet_name
  address_prefixes     = ["10.0.1.0/24"]
}


resource "azurerm_public_ip" "example" {
  name                = "public_IP"
  resource_group_name = azurerm_resource_group.ridham_res.name
  location            = azurerm_resource_group.ridham_res.location
  allocation_method   = "Static"
}


resource "azurerm_network_security_group" "nsg" {
  name                = "TestNSG"
  location            = azurerm_resource_group.ridham_res.location
  resource_group_name = azurerm_resource_group.ridham_res.name

  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "22"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}


resource "azurerm_network_interface" "test_nic" {
  name                = "test-nic"
  location            = azurerm_resource_group.ridham_res.location
  resource_group_name = azurerm_resource_group.ridham_res.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.ridham_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example.id
  }
}

resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.test_nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}


resource "azurerm_linux_virtual_machine" "ridham_vm" {
  name                            = "test-vm"
  resource_group_name             = azurerm_resource_group.ridham_res.name
  location                        = azurerm_resource_group.ridham_res.location
  size                            = "Standard_F2"
  admin_username                  = "ridham"
  admin_password                  = "Ridham@12345"
  disable_password_authentication = "false"
  network_interface_ids = [
    azurerm_network_interface.test_nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}
