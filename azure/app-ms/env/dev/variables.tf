# Project name
variable "pjname" {
  default = "nautibledev"
}
# location
variable "location" {
  default = "japaneast"
}

# product db subnet cidr
variable "product_db_subnet_cidr" {
  default = "192.170.0.0/16"
}

# product db sku
variable "product_db_sku" {
  default = "B_Standard_B1s"
}

# order redis(dapr_statestore) capacity
variable "order_redis_capacity" {
  default = 0
}

# order redis(dapr_statestore) family
variable "order_redis_family" {
  default = "C"
}

# order redis(dapr_statestore) sku_name
variable "order_redis_sku_name" {
  default = "Basic"
}

# servicebus sku
variable "servicebus_sku" {
  default = "Standard"
}

# servicebus max delivery count
variable "servicebus_max_delivery_count" {
  default = 10
}

# servicebus max size in megabytes
variable "servicebus_max_size_in_megabytes" {
  default = 1024
}

# cosmosdb public network access enabled
variable "cosmosdb_public_network_access_enabled" {
  default = true
}

# cosmosdb enable free tier
variable "cosmosdb_enable_free_tier" {
  default = true
}

