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

  default_ttl_seconds = 0
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
  capacity                      = var.order_redis_capacity
  family                        = var.order_redis_family
  sku_name                      = var.order_redis_sku_name
  enable_non_ssl_port           = false
  public_network_access_enabled = true
  redis_configuration {
  }
}

# resource "azurerm_private_endpoint" "order_dapr_statestore_pe" {
#   name                = "${var.pjname}orderstatestorepe"
#   location            = azurerm_resource_group.order_rg.location
#   resource_group_name = azurerm_resource_group.order_rg.name
#   subnet_id           = var.private_subnet_ids[0]

#   private_service_connection {
#     name                           = "${var.pjname}orderstatestorepsc"
#     private_connection_resource_id = azurerm_redis_cache.order_dapr_statestore.id
#     is_manual_connection           = false
#     subresource_names = ["redisCache"]
#   }
# }

# resource "azurerm_private_dns_a_record" "order_dapr_statestore_dns_a_record" {
#   name                = "${var.pjname}orderstatestore"
#   zone_name           = "privatelink.redis.cache.windows.net"
#   resource_group_name = "${var.pjname}common"
#   ttl                 = 300
#   records             = [azurerm_private_endpoint.order_dapr_statestore_pe.private_service_connection[0].private_ip_address]

#   depends_on = [module.common.azurerm_private_dns_zone.privatelink_redis_cache_private_dns_zone]
# }

resource "azurerm_servicebus_topic" "create_order_reply" {
  name                  = "create-order-reply"
  resource_group_name   = "${var.pjname}common"
  namespace_name        = "${var.pjname}servicebusns"
  max_size_in_megabytes = var.servicebus_max_size_in_megabytes
}

resource "azurerm_servicebus_subscription" "create_order_reply_subscription" {
  name                = "nautible-app-order"
  resource_group_name = "${var.pjname}common"
  namespace_name      = "${var.pjname}servicebusns"
  topic_name          = azurerm_servicebus_topic.create_order_reply.name
  max_delivery_count  = var.servicebus_max_delivery_count
}
