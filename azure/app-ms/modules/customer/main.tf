data "azurerm_cosmosdb_account" "cosmosdb_account" {
  name                = "${var.pjname}cosmosdb"
  resource_group_name = var.rgname
}

resource "azurerm_cosmosdb_mongo_database" "customer" {
  name                = "Customer"
  resource_group_name = data.azurerm_cosmosdb_account.cosmosdb_account.resource_group_name
  account_name        = data.azurerm_cosmosdb_account.cosmosdb_account.name
  throughput          = 400
}

resource "azurerm_cosmosdb_mongo_collection" "customer" {
  name                = "Customer"
  resource_group_name = data.azurerm_cosmosdb_account.cosmosdb_account.resource_group_name
  account_name        = data.azurerm_cosmosdb_account.cosmosdb_account.name
  database_name       = azurerm_cosmosdb_mongo_database.customer.name

  default_ttl_seconds = "-1"
  shard_key           = "_id"
  index {
    keys   = ["_id"]
    unique = true
  }
}
