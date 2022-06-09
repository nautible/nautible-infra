data "azurerm_cosmosdb_account" "cosmosdb_account" {
  name                = "${var.pjname}cosmosdb"
  resource_group_name = "${var.pjname}common"
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
  shard_key           = "orderNo"

  index {
    keys   = ["_id"]
    unique = true
  }

  index {
    keys   = ["orderNo"]
    unique = true
  }

  index {
    keys   = ["customerId", "orderDate"]
  }
}

resource "azurerm_cosmosdb_mongo_collection" "credit_payment" {
  name                = "CreditPayment"
  resource_group_name = data.azurerm_cosmosdb_account.cosmosdb_account.resource_group_name
  account_name        = data.azurerm_cosmosdb_account.cosmosdb_account.name
  database_name       = azurerm_cosmosdb_mongo_database.payment.name

  default_ttl_seconds = "-1"
  shard_key           = "acceptNo"

  index {
    keys   = ["_id"]
    unique = true
  }

  index {
    keys   = ["acceptNo"]
    unique = true
  }

}

resource "azurerm_cosmosdb_mongo_collection" "payment_allocate_history" {
  name                = "PaymentAllocateHistory"
  resource_group_name = data.azurerm_cosmosdb_account.cosmosdb_account.resource_group_name
  account_name        = data.azurerm_cosmosdb_account.cosmosdb_account.name
  database_name       = azurerm_cosmosdb_mongo_database.payment.name

  default_ttl_seconds = "-1"
  shard_key           = "requestId"

  index {
    keys   = ["_id"]
    unique = true
  }

  index {
    keys = ["requestId"]
    unique = true
  }
}

resource "azurerm_resource_group" "payment_rg" {
  name     = "${var.pjname}payment"
  location = var.location
  tags     = {}
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
