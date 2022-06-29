resource "azurerm_resource_group" "product_rg" {
  name     = "${var.pjname}product"
  location = var.location
  tags     = {}
}

resource "azurerm_private_dns_zone" "product_pdz" {
  name                         = "product-fs.private.mysql.database.azure.com"
  resource_group_name          = azurerm_resource_group.product_rg.name
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
  delegated_subnet_id          = var.subnet_ids[2]
  private_dns_zone_id          = azurerm_private_dns_zone.product_pdz.id
  sku_name                     = "GP_Standard_D2ds_v4"
  zone                         = "1"

  high_availability {
    mode                       = "ZoneRedundant"
    standby_availability_zone  = "2"
  }

  depends_on = [azurerm_private_dns_zone_virtual_network_link.product_pdz_vnl]
}

resource "azurerm_mysql_flexible_database" "product_fd" {
  name                         = "product-db"
  resource_group_name          = azurerm_resource_group.product_rg.name
  server_name                  = azurerm_mysql_flexible_server.product_fs.name
  charset                      = "utf8"
  collation                    = "utf8_unicode_ci"
}
