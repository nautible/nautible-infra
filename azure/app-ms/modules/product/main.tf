resource "azurerm_resource_group" "product_rg" {
  name     = "${var.pjname}product"
  location = var.location
  tags     = {}
}

resource "azurerm_subnet" "product_db_subnet" {
  name                                           = "${var.pjname}productdbsubnet"
  resource_group_name                            = var.vnet_rg_name
  virtual_network_name                           = var.vnet_name
  address_prefixes                               = [var.product_db_subnet_cidr]
  service_endpoints                              = ["Microsoft.Storage"]
  enforce_private_link_endpoint_network_policies = true

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
  location            = azurerm_resource_group.product_rg.location
  resource_group_name = azurerm_resource_group.product_rg.name

  security_rule {
    name                                  = "mysql"
    priority                              = 500
    direction                             = "Inbound"
    access                                = "Allow"
    protocol                              = "Tcp"
    source_port_range                     = "*"
    destination_port_range                = "3306"
    source_address_prefix                 = var.aks_aci_subnet_cidr
    destination_address_prefix            = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "product_db_subnet_nsga" {
  subnet_id                 = azurerm_subnet.product_db_subnet.id
  network_security_group_id = azurerm_network_security_group.product_db_sg.id
}

resource "azurerm_private_dns_zone" "product_pdz" {
  name                         = "product-fs.private.mysql.database.azure.com"
  resource_group_name          = azurerm_resource_group.product_rg.name

  depends_on = [azurerm_subnet_network_security_group_association.product_db_subnet_nsga]
}

resource "azurerm_private_dns_zone_virtual_network_link" "product_pdz_vnl" {
  name                         = "productFsVnetZone.com"
  private_dns_zone_name        = azurerm_private_dns_zone.product_pdz.name
  virtual_network_id           = var.vnet_id
  resource_group_name          = azurerm_resource_group.product_rg.name
  registration_enabled         = true
}

data "azurerm_key_vault" "nautible_key_vault" {
  name                         = "nautibledevkeyvault"
  resource_group_name          = "nautibledevkeyvault"
}

data "azurerm_key_vault_secret" "product_db_user" {
  name                         = "nautible-app-ms-product-db-user"
  key_vault_id                 = data.azurerm_key_vault.nautible_key_vault.id
}

data "azurerm_key_vault_secret" "product_db_password" {
  name                         = "nautible-app-ms-product-db-password"
  key_vault_id                 = data.azurerm_key_vault.nautible_key_vault.id
}

resource "azurerm_mysql_flexible_server" "product_fs" {
  name                         = "product-fs"
  resource_group_name          = azurerm_resource_group.product_rg.name
  location                     = azurerm_resource_group.product_rg.location
  administrator_login          = data.azurerm_key_vault_secret.product_db_user.value
  administrator_password       = data.azurerm_key_vault_secret.product_db_password.value
  version                      = "5.7"
  delegated_subnet_id          = azurerm_subnet.product_db_subnet.id
  private_dns_zone_id          = azurerm_private_dns_zone.product_pdz.id
  sku_name                     = var.product_db_sku
  zone                         = "1"

  depends_on = [azurerm_private_dns_zone_virtual_network_link.product_pdz_vnl]
}

resource "azurerm_mysql_flexible_server_configuration" "product_fsc" {
  name                = "require_secure_transport"
  resource_group_name = azurerm_resource_group.product_rg.name
  server_name         = azurerm_mysql_flexible_server.product_fs.name
  value               = "OFF"
}

resource "azurerm_mysql_flexible_database" "product_fd" {
  name                         = "product-db"
  resource_group_name          = azurerm_resource_group.product_rg.name
  server_name                  = azurerm_mysql_flexible_server.product_fs.name
  charset                      = "utf8"
  collation                    = "utf8_unicode_ci"
}
