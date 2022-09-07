data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "common_rg" {
  name     = "${var.pjname}common"
  location = var.location
  tags     = {}
}

resource "azurerm_cosmosdb_account" "cosmosdb_account" {
  name                          = "${var.pjname}cosmosdb"
  location                      = azurerm_resource_group.common_rg.location
  resource_group_name           = azurerm_resource_group.common_rg.name
  offer_type                    = "Standard"
  kind                          = "MongoDB"
  public_network_access_enabled = var.cosmosdb_public_network_access_enabled

  capabilities {
    name = "EnableMongo"
  }

  capabilities {
    name = "DisableRateLimitingResponses"
  }

  consistency_policy {
    consistency_level       = "Eventual"
    max_interval_in_seconds = 5
    max_staleness_prefix    = 100
  }

  geo_location {
    location          = azurerm_resource_group.common_rg.location
    failover_priority = 0
  }

  enable_free_tier       = var.cosmosdb_enable_free_tier
  network_acl_bypass_ids = []
  tags                   = {}
  # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cosmosdb_account#ip_range_filter
  # https://docs.microsoft.com/ja-jp/azure/cosmos-db/how-to-configure-firewall#allow-requests-from-the-azure-portal
  ip_range_filter = "104.42.195.92,40.76.54.131,52.176.6.30,52.169.50.45,52.187.184.26"
}

resource "azurerm_private_endpoint" "cosmosdb_account_pe" {
  name                = "${var.pjname}cosmosdb"
  location            = azurerm_resource_group.common_rg.location
  resource_group_name = azurerm_resource_group.common_rg.name
  subnet_id           = var.aks_subnet_ids[0]

  private_service_connection {
    name                           = "${var.pjname}cosmosdb"
    private_connection_resource_id = azurerm_cosmosdb_account.cosmosdb_account.id
    is_manual_connection           = false
    subresource_names              = ["MongoDB"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.cosmosdb_private_dns_zone_id]
  }
}

resource "azurerm_cosmosdb_mongo_database" "common" {
  name                = "Common"
  resource_group_name = azurerm_cosmosdb_account.cosmosdb_account.resource_group_name
  account_name        = azurerm_cosmosdb_account.cosmosdb_account.name
  throughput          = 400
}

resource "azurerm_cosmosdb_mongo_collection" "sequence" {
  name                = "Sequence"
  resource_group_name = azurerm_cosmosdb_account.cosmosdb_account.resource_group_name
  account_name        = azurerm_cosmosdb_account.cosmosdb_account.name
  database_name       = azurerm_cosmosdb_mongo_database.common.name

  default_ttl_seconds = "-1"
  shard_key           = "_id"
  index {
    keys   = ["_id"]
    unique = true
  }
}

resource "azurerm_servicebus_namespace" "servicebus_namespace" {
  name                = "${var.pjname}servicebusns"
  location            = azurerm_resource_group.common_rg.location
  resource_group_name = azurerm_resource_group.common_rg.name
  sku                 = var.servicebus_sku
  capacity            = var.servicebus_capacity
  tags                = {}
}

resource "azurerm_servicebus_namespace_network_rule_set" "servicebus_namespace_network_rule_set" {
  count                         = var.servicebus_sku == "Premium" ? 1 : 0
  namespace_id                  = azurerm_servicebus_namespace.servicebus_namespace.id
  default_action                = "Allow"
  public_network_access_enabled = false
  trusted_services_allowed      = true
}

resource "azurerm_private_endpoint" "servicebus_pe" {
  count               = var.servicebus_sku == "Premium" ? 1 : 0
  name                = "${var.pjname}appmsservicebus"
  location            = azurerm_resource_group.common_rg.location
  resource_group_name = azurerm_resource_group.common_rg.name
  subnet_id           = var.aks_subnet_ids[0]

  private_service_connection {
    name                           = "${var.pjname}appmsservicebus"
    private_connection_resource_id = azurerm_servicebus_namespace.servicebus_namespace.id
    is_manual_connection           = false
    subresource_names              = ["namespace"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.servicebus_private_dns_zone_id]
  }
}

resource "azurerm_key_vault" "keyvault" {
  name                       = "${var.pjname}appms"
  location                   = azurerm_resource_group.common_rg.location
  resource_group_name        = azurerm_resource_group.common_rg.name
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
  name                = "${var.pjname}appmskeyvault"
  location            = azurerm_resource_group.common_rg.location
  resource_group_name = azurerm_resource_group.common_rg.name
  subnet_id           = var.aks_subnet_ids[0]

  private_service_connection {
    name                           = "${var.pjname}appmskeyvault"
    private_connection_resource_id = azurerm_key_vault.keyvault.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.keyvault_private_dns_zone_id]
  }
}