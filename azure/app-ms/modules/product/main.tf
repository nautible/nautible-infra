resource "azurerm_subnet" "product_db_subnet" {
  name                                          = "${var.pjname}productdbsubnet"
  resource_group_name                           = var.rgname
  virtual_network_name                          = var.vnet_name
  address_prefixes                              = [var.product_db_subnet_cidr]
  service_endpoints                             = ["Microsoft.Storage"]
  private_link_service_network_policies_enabled = true

  delegation {
    name = "productDbDelegation"
    service_delegation {
      name    = "Microsoft.DBforMySQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_network_security_group" "product_db_sg" {
  name                = "${var.pjname}productdbsg"
  location            = var.location
  resource_group_name = var.rgname

  security_rule {
    name                       = "mysql"
    priority                   = 500
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3306"
    source_address_prefix      = var.aks_aci_subnet_cidr
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "product_db_subnet_nsga" {
  subnet_id                 = azurerm_subnet.product_db_subnet.id
  network_security_group_id = azurerm_network_security_group.product_db_sg.id
}

resource "azurerm_private_dns_zone" "product_pdz" {
  name                = "product-fs.private.mysql.database.azure.com"
  resource_group_name = var.rgname

  depends_on = [azurerm_subnet_network_security_group_association.product_db_subnet_nsga]
}

resource "azurerm_private_dns_zone_virtual_network_link" "product_pdz_vnl" {
  name                  = "productFsVnetZone.com"
  private_dns_zone_name = azurerm_private_dns_zone.product_pdz.name
  virtual_network_id    = var.vnet_id
  resource_group_name   = var.rgname
  registration_enabled  = true
}

resource "azurerm_mysql_flexible_server" "product_fs" {
  name                = "product-fs"
  resource_group_name = var.rgname
  location            = var.location
  # 初回以外は入力を求めないようにするため、また、ブランクの場合常にエラーになってしまうのでdummyを設定する。
  administrator_login    = coalesce(var.product_db_administrator_login, "dummy")
  administrator_password = coalesce(var.product_db_administrator_password, "Dummy123")
  version                = "8.0.21"
  delegated_subnet_id    = azurerm_subnet.product_db_subnet.id
  private_dns_zone_id    = azurerm_private_dns_zone.product_pdz.id
  sku_name               = var.product_db_sku
  zone                   = var.product_db_zone

  depends_on = [azurerm_private_dns_zone_virtual_network_link.product_pdz_vnl]
  lifecycle {
    ignore_changes = [
      administrator_login, administrator_password
    ]
  }
}

resource "azurerm_mysql_flexible_server_configuration" "product_fsc" {
  name                = "require_secure_transport"
  resource_group_name = var.rgname
  server_name         = azurerm_mysql_flexible_server.product_fs.name
  value               = "OFF"
}

resource "azurerm_mysql_flexible_database" "product_fd" {
  name                = "product-db"
  resource_group_name = var.rgname
  server_name         = azurerm_mysql_flexible_server.product_fs.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}
