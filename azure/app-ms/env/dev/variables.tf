# Project name
variable "pjname" {
  default = "nautibledev"
}
# location
variable "location" {
  default = "japaneast"
}

# common
variable "common" {
  description = "order設定"
  type = object({
    servicebus = object({
      capacity              = number
      max_delivery_count    = number
      max_size_in_megabytes = number
    })
    cosmosdb = object({
      public_network_access_enabled = bool
      enable_free_tier              = bool
    })

  })
  default = {
    servicebus = {
      # capacity
      capacity = 1
      # max delivery count
      max_delivery_count = 10
      # max size in megabytes
      max_size_in_megabytes = 1024
    }
    cosmosdb = {
      # public network access enabled
      public_network_access_enabled = true
      # enable free tier
      enable_free_tier = true
    }
  }
}

# product
variable "product" {
  description = "product設定"
  type = object({
    db = object({
      subnet_cidr = string
      sku         = string
    })
  })
  default = {
    db = {
      # db subnet cidr
      subnet_cidr = "192.170.0.0/16"
      # db sku
      sku = "B_Standard_B1s"
    }
  }
}

# order
variable "order" {
  description = "order設定"
  type = object({
    redis = object({
      capacity = number
      family   = string
      sku      = string
    })
  })
  default = {
    redis = {
      # redis(dapr_statestore) capacity
      capacity = 0
      # redis(dapr_statestore) family
      family = "C"
      # redis(dapr_statestore) sku
      sku = "Basic"
    }
  }
}

variable "product_db_administrator_login" {
  description = "商品サービスで利用するDBのadminユーザーID。初回のみ入力する。初回以外の場合はEnterで入力をスキップする。"
}
variable "product_db_administrator_password" {
  description = "商品サービスで利用するDBのパスワード。初回のみ入力する。初回以外の場合はEnterで入力をスキップする。"
}

# servicebus sku
# Premium の場合はパブリックアクセスを無効化、プライベートエンドポイントでアクセスする
# ※Premiumは127円/1hで月額700ドルかかるため注意が必要
variable "servicebus_sku" {
  description = "Azure ServiceBusの価格レベル(sku)。[Basic Standard Premium]のいずれかを指定する。★★★ Premiumは127円/1hで月額700ドルかかるため注意。Premium の場合はパブリックアクセスを無効化、プライベートエンドポイントでアクセスする。"
}
