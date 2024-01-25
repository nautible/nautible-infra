resource "azurerm_virtual_network" "vnet" {
  name                = "${var.pjname}vnet"
  resource_group_name = var.rgname
  location            = var.location
  address_space       = [var.vnet_cidr]
  dns_servers         = []
  tags                = {}
}
