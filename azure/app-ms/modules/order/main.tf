data "azurerm_cosmosdb_account" "cosmosdb_account" {
  name                = "${var.pjname}cosmosdb"
  resource_group_name = "${var.pjname}common"
}

resource "azurerm_cosmosdb_mongo_database" "order" {
  name                = "Order"
  resource_group_name = data.azurerm_cosmosdb_account.cosmosdb_account.resource_group_name
  account_name        = data.azurerm_cosmosdb_account.cosmosdb_account.name
  throughput          = 400
}

resource "azurerm_cosmosdb_mongo_collection" "order" {
  name                = "Order"
  resource_group_name = data.azurerm_cosmosdb_account.cosmosdb_account.resource_group_name
  account_name        = data.azurerm_cosmosdb_account.cosmosdb_account.name
  database_name       = azurerm_cosmosdb_mongo_database.order.name

  default_ttl_seconds = "-1"
  shard_key           = "_id"
  index {
    keys   = ["_id"]
    unique = true
  }
}

resource "azurerm_resource_group" "order_rg" {
  name     = "${var.pjname}order"
  location = var.location
  tags     = {}
}

resource "azurerm_redis_cache" "order_dapr_statestore" {
  # NOTE: the Name used for Redis needs to be globally unique
  name                          = "${var.pjname}orderstatestore"
  location                      = azurerm_resource_group.order_rg.location
  resource_group_name           = azurerm_resource_group.order_rg.name
  redis_version                 = var.order_redis_version
  capacity                      = var.order_redis_capacity
  family                        = var.order_redis_family
  sku_name                      = var.order_redis_sku
  enable_non_ssl_port           = false
  public_network_access_enabled = false
  redis_configuration {
  }
}

resource "azurerm_private_endpoint" "order_dapr_statestore_pe" {
  name                = "${var.pjname}orderstatestore"
  location            = azurerm_resource_group.order_rg.location
  resource_group_name = azurerm_resource_group.order_rg.name
  subnet_id           = var.aks_subnet_ids[0]

  private_service_connection {
    name                           = "${var.pjname}orderstatestore"
    private_connection_resource_id = azurerm_redis_cache.order_dapr_statestore.id
    is_manual_connection           = false
    subresource_names              = ["redisCache"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.redis_private_dns_zone_id]
  }

}

resource "azurerm_servicebus_topic" "create_order_reply_topic" {
  name                  = "create-order-reply"
  namespace_id          = var.servicebus_namespace_id
  max_size_in_megabytes = var.servicebus_max_size_in_megabytes
}

resource "azurerm_servicebus_subscription" "create_order_reply_subscription" {
  name               = "nautible-app-order"
  topic_id           = azurerm_servicebus_topic.create_order_reply_topic.id
  max_delivery_count = var.servicebus_max_delivery_count
}
