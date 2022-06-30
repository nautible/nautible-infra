resource "azurerm_resource_group" "vnet_rg" {
  name     = "${var.pjname}vnet"
  location = var.location
  tags     = {}
}

# don't use "Azure/vnet/azurerm" module.
# it can't def subnet delegation.

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.pjname}vnet"
  resource_group_name = azurerm_resource_group.vnet_rg.name
  location            = azurerm_resource_group.vnet_rg.location
  address_space       = [var.vnet_cidr]
  dns_servers         = []
  tags                = {}
}

resource "azurerm_subnet" "subnet" {
  count                                          = length(var.subnet_names)
  name                                           = var.subnet_names[count.index]
  resource_group_name                            = azurerm_resource_group.vnet_rg.name
  virtual_network_name                           = azurerm_virtual_network.vnet.name
  address_prefixes                               = [var.subnet_cidrs[count.index]]
  service_endpoints                              = var.subnet_names[count.index] == "mysqlprivatesubnet" ? ["Microsoft.Storage"] : ["Microsoft.KeyVault"]
  enforce_private_link_endpoint_network_policies = true

  dynamic "delegation" {
    for_each = var.subnet_names[count.index] == "aksaciprivatesubnet" ? [{
        delegation_name            = "aciDelegation"
        service_delegation_name    = "Microsoft.ContainerInstance/containerGroups"
        service_delegation_actions = [ "Microsoft.Network/virtualNetworks/subnets/action" ]
      }] : var.subnet_names[count.index] == "mysqlprivatesubnet" ? [{
        delegation_name            = "mysqlDelegation"
        service_delegation_name    = "Microsoft.DBforMySQL/flexibleServers"
        service_delegation_actions = [ "Microsoft.Network/virtualNetworks/subnets/join/action" ]
      }] : []
    content {
      name = delegation.value["delegation_name"]
      service_delegation {
        name    = delegation.value["service_delegation_name"]
        actions = delegation.value["service_delegation_actions"]
      }
    }
  }
}

resource "azurerm_network_security_group" "private" {
  name                = "${var.pjname}privatesg"
  location            = azurerm_resource_group.vnet_rg.location
  resource_group_name = azurerm_resource_group.vnet_rg.name
}

resource "azurerm_network_security_group" "web" {
  name                = "${var.pjname}webesg"
  location            = azurerm_resource_group.vnet_rg.location
  resource_group_name = azurerm_resource_group.vnet_rg.name

  security_rule {
    name                       = "https"
    priority                   = 500
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  dynamic "security_rule" {
    for_each = var.web_http_port_range != null && var.web_http_port_range != "" ? ["true"] : []
    content {
      name                       = "http"
      priority                   = 501
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = var.web_http_port_range
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }

}

resource "azurerm_network_security_group" "mysql_private" {
  name                = "${var.pjname}mysqlprivatesg"
  location            = azurerm_resource_group.vnet_rg.location
  resource_group_name = azurerm_resource_group.vnet_rg.name

  security_rule {
    name                                  = "mysql"
    priority                              = 500
    direction                             = "Inbound"
    access                                = "Allow"
    protocol                              = "Tcp"
    source_port_range                     = "*"
    destination_port_range                = "3306"
    source_address_prefix                 = var.subnet_cidrs[1]
    destination_address_prefix            = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "web_subnet_nsga" {
  subnet_id                 = azurerm_subnet.subnet[0].id
  network_security_group_id = azurerm_network_security_group.web.id
}

resource "azurerm_subnet_network_security_group_association" "private_subnet_nsga" {
  subnet_id                 = azurerm_subnet.subnet[1].id
  network_security_group_id = azurerm_network_security_group.private.id
}

resource "azurerm_subnet_network_security_group_association" "mysql_private_subnet_nsga" {
  subnet_id                 = azurerm_subnet.subnet[2].id
  network_security_group_id = azurerm_network_security_group.mysql_private.id
}
