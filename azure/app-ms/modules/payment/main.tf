data "azurerm_cosmosdb_account" "cosmosdb_account" {
  name                = "${var.pjname}cosmosdb"
  resource_group_name = var.rgname
}

resource "azurerm_cosmosdb_mongo_database" "payment" {
  name                = "Payment"
  resource_group_name = data.azurerm_cosmosdb_account.cosmosdb_account.resource_group_name
  account_name        = data.azurerm_cosmosdb_account.cosmosdb_account.name
  throughput          = 400
}

resource "azurerm_cosmosdb_mongo_collection" "payment" {
  name                = "Payment"
  resource_group_name = data.azurerm_cosmosdb_account.cosmosdb_account.resource_group_name
  account_name        = data.azurerm_cosmosdb_account.cosmosdb_account.name
  database_name       = azurerm_cosmosdb_mongo_database.payment.name

  default_ttl_seconds = "-1"
  shard_key           = "OrderNo"

  index {
    keys   = ["_id"]
    unique = true
  }

  index {
    keys   = ["OrderNo"]
    unique = true
  }

  index {
    keys = ["CustomerId", "OrderDate"]
  }
}

resource "azurerm_cosmosdb_mongo_collection" "credit_payment" {
  name                = "CreditPayment"
  resource_group_name = data.azurerm_cosmosdb_account.cosmosdb_account.resource_group_name
  account_name        = data.azurerm_cosmosdb_account.cosmosdb_account.name
  database_name       = azurerm_cosmosdb_mongo_database.payment.name

  default_ttl_seconds = "-1"
  shard_key           = "AcceptNo"

  index {
    keys   = ["_id"]
    unique = true
  }

  index {
    keys   = ["AcceptNo"]
    unique = true
  }

}

resource "azurerm_cosmosdb_mongo_collection" "payment_allocate_history" {
  name                = "PaymentAllocateHistory"
  resource_group_name = data.azurerm_cosmosdb_account.cosmosdb_account.resource_group_name
  account_name        = data.azurerm_cosmosdb_account.cosmosdb_account.name
  database_name       = azurerm_cosmosdb_mongo_database.payment.name

  default_ttl_seconds = "-1"
  shard_key           = "RequestId"

  index {
    keys   = ["_id"]
    unique = true
  }

  index {
    keys   = ["RequestId"]
    unique = true
  }
}

resource "azurerm_servicebus_topic" "payment_create_topic" {
  name                  = "payment-create"
  namespace_id          = var.servicebus_namespace_id
  max_size_in_megabytes = var.servicebus_max_size_in_megabytes
}

resource "azurerm_servicebus_topic" "payment_reject_create_topic" {
  name                  = "payment-reject-create"
  namespace_id          = var.servicebus_namespace_id
  max_size_in_megabytes = var.servicebus_max_size_in_megabytes
}

resource "azurerm_servicebus_subscription" "payment_reserve_create_subscription" {
  name               = "nautible-app-payment"
  topic_id           = azurerm_servicebus_topic.payment_create_topic.id
  max_delivery_count = var.servicebus_max_delivery_count
}

resource "azurerm_servicebus_subscription" "payment_reject_create_subscription" {
  name               = "nautible-app-payment"
  topic_id           = azurerm_servicebus_topic.payment_reject_create_topic.id
  max_delivery_count = var.servicebus_max_delivery_count
}
