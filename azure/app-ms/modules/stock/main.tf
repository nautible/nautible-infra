data "azurerm_cosmosdb_account" "cosmosdb_account" {
  name                = "${var.pjname}cosmosdb"
  resource_group_name = "${var.pjname}common"
}

resource "azurerm_cosmosdb_mongo_database" "stock" {
  name                = "Stock"
  resource_group_name = data.azurerm_cosmosdb_account.cosmosdb_account.resource_group_name
  account_name        = data.azurerm_cosmosdb_account.cosmosdb_account.name
  throughput          = 400
}

resource "azurerm_cosmosdb_mongo_collection" "stock" {
  name                = "Stock"
  resource_group_name = data.azurerm_cosmosdb_account.cosmosdb_account.resource_group_name
  account_name        = data.azurerm_cosmosdb_account.cosmosdb_account.name
  database_name       = azurerm_cosmosdb_mongo_database.stock.name

  default_ttl_seconds = "-1"
  shard_key           = "ProductId"

  index {
    keys   = ["_id"]
    unique = true
  }

  index {
    keys   = ["ProductId"]
    unique = true
  }

}

resource "azurerm_cosmosdb_mongo_collection" "stock_allocate_history" {
  name                = "StockAllocateHistory"
  resource_group_name = data.azurerm_cosmosdb_account.cosmosdb_account.resource_group_name
  account_name        = data.azurerm_cosmosdb_account.cosmosdb_account.name
  database_name       = azurerm_cosmosdb_mongo_database.stock.name

  default_ttl_seconds = "-1"
  shard_key           = "RequestId"

  index {
    keys   = ["_id"]
    unique = true
  }

  index {
    keys = ["RequestId"]
  }

  index {
    keys   = ["RequestId", "ProductId"]
    unique = true
  }

}

resource "azurerm_resource_group" "stock_rg" {
  name     = "${var.pjname}stock"
  location = var.location
  tags     = {}
}

resource "azurerm_servicebus_topic" "stock_reserve_allocate_topic" {
  name                  = "stock-reserve-allocate"
  namespace_id          = var.servicebus_namespace_id
  max_size_in_megabytes = var.servicebus_max_size_in_megabytes
}

resource "azurerm_servicebus_topic" "stock_reject_allocate_topic" {
  name                  = "stock-reject-allocate"
  namespace_id          = var.servicebus_namespace_id
  max_size_in_megabytes = var.servicebus_max_size_in_megabytes
}

resource "azurerm_servicebus_topic" "stock_approve_allocate_topic" {
  name                  = "stock-approve-allocate"
  namespace_id          = var.servicebus_namespace_id
  max_size_in_megabytes = var.servicebus_max_size_in_megabytes
}

resource "azurerm_servicebus_subscription" "stock_reserve_allocate_subscription" {
  name               = "nautible-app-stock"
  topic_id           = azurerm_servicebus_topic.stock_reserve_allocate_topic.id
  max_delivery_count = var.servicebus_max_delivery_count
}

resource "azurerm_servicebus_subscription" "stock_reject_allocate_subscription" {
  name               = "nautible-app-stock"
  topic_id           = azurerm_servicebus_topic.stock_reject_allocate_topic.id
  max_delivery_count = var.servicebus_max_delivery_count
}

resource "azurerm_servicebus_subscription" "stock_approve_allocate_subscription" {
  name               = "nautible-app-stock"
  topic_id           = azurerm_servicebus_topic.stock_approve_allocate_topic.id
  max_delivery_count = var.servicebus_max_delivery_count
}
