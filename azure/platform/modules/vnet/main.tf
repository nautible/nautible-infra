resource "azurerm_resource_group" "vnet_rg" {
  name     = "${var.pjname}vnet"
  location = var.location
  tags     = {}
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.pjname}vnet"
  resource_group_name = azurerm_resource_group.vnet_rg.name
  location            = azurerm_resource_group.vnet_rg.location
  address_space       = [var.vnet_cidr]
  dns_servers         = []
  tags                = {}
}
