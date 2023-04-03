data "azurerm_cosmosdb_account" "cosmosdb_account" {
  name                = "${var.pjname}cosmosdb"
  resource_group_name = "${var.pjname}common"
}

resource "azurerm_cosmosdb_mongo_database" "delivery" {
  name                = "Delivery"
  resource_group_name = data.azurerm_cosmosdb_account.cosmosdb_account.resource_group_name
  account_name        = data.azurerm_cosmosdb_account.cosmosdb_account.name
  throughput          = 400
}

resource "azurerm_cosmosdb_mongo_collection" "delivery" {
  name                = "Delivery"
  resource_group_name = data.azurerm_cosmosdb_account.cosmosdb_account.resource_group_name
  account_name        = data.azurerm_cosmosdb_account.cosmosdb_account.name
  database_name       = azurerm_cosmosdb_mongo_database.delivery.name

  default_ttl_seconds = "-1"
  shard_key           = "DeliveryNo"

  index {
    keys   = ["_id"]
    unique = true
  }

  index {
    keys   = ["DeliveryNo"]
    unique = true
  }

}

resource "azurerm_resource_group" "delivery_rg" {
  name     = "${var.pjname}delivery"
  location = var.location
  tags     = {}
}
