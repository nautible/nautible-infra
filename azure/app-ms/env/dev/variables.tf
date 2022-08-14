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
variable "product_db_administrator_login" {
  description = "商品サービスで利用するDBのadminユーザーID。初回のみ入力する。初回以外の場合はEnterで入力をスキップする。"
}
variable "product_db_administrator_password" {
  description = "商品サービスで利用するDBのパスワード。初回のみ入力する。初回以外の場合はEnterで入力をスキップする。"
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
# Premium の場合はパブリックアクセスを無効化、プライベートエンドポイントでアクセスする
# ※Premiumは127円/1hで月額700ドルかかるため注意が必要
variable "servicebus_sku" {
  # default = "Standard"
  default = "Premium"
}

# servicebus capacity
variable "servicebus_capacity" {
  default = 1
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

