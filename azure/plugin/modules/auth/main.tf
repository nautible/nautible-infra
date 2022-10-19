data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "keycloak_rg" {
  name     = "${var.pjname}keycloak"
  location = var.location
  tags     = {}
}

resource "azurerm_subnet" "subnet" {
  name                 = var.postgres_subnet_name
  resource_group_name  = var.vnet_rg_name
  virtual_network_name = var.vnet_name
  address_prefixes     = [var.postgres_subnet_cidr]
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
  name                = "keycloakdbserver"
  resource_group_name = azurerm_resource_group.keycloak_rg.name
  location            = azurerm_resource_group.keycloak_rg.location
  version             = var.postgres_version
  delegated_subnet_id = azurerm_subnet.subnet.id
  private_dns_zone_id = azurerm_private_dns_zone.keycloak_db_dns_zone.id
  # 初回以外は入力を求めないようにするため、また、ブランクの場合常にエラーになってしまうのでdummyを設定する。
  # 以下の値では作成時にエラーとなるためダミー値でDBは作成されることはない。
  # 8～128文字、英大文字、英小文字、数字 (0 ～ 9)、英数字以外の文字 (!、$、#、% など) のうち、3 つのカテゴリの文字が含まれている
  administrator_login    = coalesce(var.postgres_administrator_login, "dummy")
  administrator_password = coalesce(var.postgres_administrator_password, "dummy")

  storage_mb            = var.postgres_storage_mb
  backup_retention_days = var.postgres_backup_retention_days
  sku_name              = var.postgres_sku_name
  zone                  = var.postgres_zone
  depends_on            = [azurerm_private_dns_zone_virtual_network_link.keycloak_db_dns_zone_vnl]

  lifecycle {
    ignore_changes = [
      administrator_login, administrator_password
    ]
  }
}

resource "azurerm_postgresql_flexible_server_database" "keycloak_db" {
  name      = "keycloak"
  server_id = azurerm_postgresql_flexible_server.keycloak_db_server.id
  charset   = "utf8"
  collation = "ja_JP.utf8"
}

resource "azurerm_key_vault" "keyvault" {
  name                       = "${var.pjname}auth"
  location                   = azurerm_resource_group.keycloak_rg.location
  resource_group_name        = azurerm_resource_group.keycloak_rg.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days = 30
  purge_protection_enabled   = false

  sku_name = "standard"
  tags     = {}
  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
  }
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

resource "azurerm_private_endpoint" "keyvault_pe" {
  name                = "${var.pjname}authkeyvault"
  location            = azurerm_resource_group.keycloak_rg.location
  resource_group_name = azurerm_resource_group.keycloak_rg.name
  subnet_id           = var.subnet_ids[0]

  private_service_connection {
    name                           = "${var.pjname}authkeyvault"
    private_connection_resource_id = azurerm_key_vault.keyvault.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.keyvault_private_dns_zone_id]
  }
}

# resource "azurerm_private_dns_zone" "keyvault_dns_zone" {
#   name                = "auth.privatelink.vaultcore.azure.net"
#   resource_group_name = azurerm_resource_group.keycloak_rg.name
# }

# resource "azurerm_private_dns_a_record" "keyvault_private_dns_a_record" {
#   name                = "${var.pjname}auth"
#   zone_name           = azurerm_private_dns_zone.keyvault_dns_zone.name
#   resource_group_name = azurerm_resource_group.keycloak_rg.name
#   ttl                 = 300
#   records             = [azurerm_private_endpoint.keyvault_pe.private_service_connection[0].private_ip_address]
# }

# resource "azurerm_private_dns_zone_virtual_network_link" "keyvault_dns_zone_virtual_network_link" {
#   name                  = "${var.pjname}auth"
#   resource_group_name   = azurerm_resource_group.keycloak_rg.name
#   private_dns_zone_name = azurerm_private_dns_zone.keyvault_dns_zone.name
#   virtual_network_id    = var.vnet_id
# }
