data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "keycloak_rg" {
  name     = "${var.pjname}keycloak"
  location = var.location
  tags     = {}
}

data "azurerm_key_vault" "keyvault" {
  name                = "${var.pjname}auth"
  resource_group_name = "${var.pjname}keyvault"
}

data "azurerm_key_vault_secret" "keycloak_db_user" {
  name         = "nautible-plugin-keycloak-db-user"
  key_vault_id = data.azurerm_key_vault.keyvault.id
}

data "azurerm_key_vault_secret" "keycloak_db_password" {
  name         = "nautible-plugin-keycloak-db-password"
  key_vault_id = data.azurerm_key_vault.keyvault.id
}

resource "azurerm_subnet" "subnet" {
  name                 = var.auth_variables.postgres.subnet_name
  resource_group_name  = var.vnet_rg_name
  virtual_network_name = var.vnet_name
  address_prefixes     = [var.auth_variables.postgres.subnet_cidr]
  service_endpoints    = ["Microsoft.Storage"]

  delegation {
    name = "authpostgresqlfs"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}


resource "azurerm_network_security_group" "subnet_sg" {
  name                = "${var.pjname}postgres"
  location            = var.location
  resource_group_name = var.vnet_rg_name

  security_rule {
    name                       = "postgres"
    priority                   = 500
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5432"
    source_address_prefix      = "192.0.0.0/8"
    destination_address_prefix = "*"
  }

}

resource "azurerm_subnet_network_security_group_association" "subnet_nsga" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.subnet_sg.id
}

# name end with .postgres.database.azure.com.
resource "azurerm_private_dns_zone" "keycloak_db_dns_zone" {
  name                = "keycloak.private.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.keycloak_rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "keycloak_db_dns_zone_vnl" {
  name                  = "keycloak.com"
  private_dns_zone_name = azurerm_private_dns_zone.keycloak_db_dns_zone.name
  virtual_network_id    = var.vnet_id
  resource_group_name   = azurerm_resource_group.keycloak_rg.name
}

# private_dns_zone_id required
resource "azurerm_postgresql_flexible_server" "keycloak_db_server" {
  name                   = "keycloakdbserver"
  resource_group_name    = azurerm_resource_group.keycloak_rg.name
  location               = azurerm_resource_group.keycloak_rg.location
  version                = var.auth_variables.postgres.version
  delegated_subnet_id    = azurerm_subnet.subnet.id
  private_dns_zone_id    = azurerm_private_dns_zone.keycloak_db_dns_zone.id
  administrator_login    = data.azurerm_key_vault_secret.keycloak_db_user.value
  administrator_password = data.azurerm_key_vault_secret.keycloak_db_password.value

  storage_mb            = var.auth_variables.postgres.storage_mb
  backup_retention_days = var.auth_variables.postgres.backup_retention_days
  sku_name              = var.auth_variables.postgres.sku_name
  zone                  = var.auth_variables.postgres.zone
  depends_on            = [azurerm_private_dns_zone_virtual_network_link.keycloak_db_dns_zone_vnl]

}

resource "azurerm_postgresql_flexible_server_database" "keycloak_db" {
  name      = "keycloak"
  server_id = azurerm_postgresql_flexible_server.keycloak_db_server.id
  charset   = "utf8"
  collation = "ja_JP.utf8"
}

resource "azurerm_key_vault" "keyvault" {
  name                       = "${var.pjname}auth"
  location                   = var.keyvault_rg.location
  resource_group_name        = var.keyvault_rg.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days = 30
  purge_protection_enabled   = false

  sku_name = "standard"
  tags     = {}
}

resource "azurerm_key_vault_access_policy" "keyvault_ap" {
  key_vault_id            = azurerm_key_vault.keyvault.id
  tenant_id               = data.azurerm_client_config.current.tenant_id
  object_id               = var.nautible_service_principal_object_id
  certificate_permissions = []
  storage_permissions     = []
  key_permissions = [
    "Get", "List"
  ]

  secret_permissions = [
    "Get", "List"
  ]
}