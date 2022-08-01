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
}

# data "azurerm_cosmosdb_account" "cosmosdb_account" {
#   name                = "${var.pjname}cosmosdb"
#   resource_group_name = "${var.pjname}cosmosdb"
# }

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

# resource "azurerm_private_dns_zone" "privatelink_redis_cache_private_dns_zone" {
#   name                = "privatelink.redis.cache.windows.net"
#   resource_group_name = azurerm_resource_group.common_rg.name
# }

resource "azurerm_servicebus_namespace" "servicebus_namespace" {
  name                = "${var.pjname}servicebusns"
  location            = azurerm_resource_group.common_rg.location
  resource_group_name = azurerm_resource_group.common_rg.name
  sku                 = var.servicebus_sku
  tags                = {}
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
