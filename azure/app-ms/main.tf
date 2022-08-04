module "common" {
  source                                 = "./modules/common"
  pjname                                 = var.pjname
  location                               = var.location
  vnet_id                                = var.vnet_id
  vnet_rg_name                           = var.vnet_rg_name
  subnet_ids                             = var.subnet_ids
  servicebus_sku                         = var.servicebus_sku
  cosmosdb_public_network_access_enabled = var.cosmosdb_public_network_access_enabled
  cosmosdb_enable_free_tier              = var.cosmosdb_enable_free_tier
  nautible_service_principal_object_id   = var.nautible_service_principal_object_id
  keyvault_private_dns_zone_id           = var.keyvault_private_dns_zone_id
  cosmosdb_private_dns_zone_id           = var.cosmosdb_private_dns_zone_id
}

module "customer" {
  source   = "./modules/customer"
  pjname   = var.pjname
  location = var.location

  depends_on = [module.common]
}

module "stock" {
  source                           = "./modules/stock"
  pjname                           = var.pjname
  location                         = var.location
  servicebus_max_delivery_count    = var.servicebus_max_delivery_count
  servicebus_max_size_in_megabytes = var.servicebus_max_size_in_megabytes
  servicebus_namespace_id          = module.common.servicebus_namespace_id
  depends_on = [module.common]
}

module "order" {
  source                           = "./modules/order"
  pjname                           = var.pjname
  location                         = var.location
  subnet_ids                       = var.subnet_ids
  vnet_id                          = var.vnet_id
  vnet_rg_name                     = var.vnet_rg_name
  order_redis_capacity             = var.order_redis_capacity
  order_redis_family               = var.order_redis_family
  order_redis_sku_name             = var.order_redis_sku_name
  servicebus_max_delivery_count    = var.servicebus_max_delivery_count
  servicebus_max_size_in_megabytes = var.servicebus_max_size_in_megabytes
  servicebus_namespace_id          = module.common.servicebus_namespace_id
  redis_private_dns_zone_id        = var.redis_private_dns_zone_id

  depends_on = [module.common]
}

module "payment" {
  source   = "./modules/payment"
  pjname   = var.pjname
  location = var.location
  servicebus_max_delivery_count    = var.servicebus_max_delivery_count
  servicebus_max_size_in_megabytes = var.servicebus_max_size_in_megabytes
  servicebus_namespace_id          = module.common.servicebus_namespace_id

  depends_on = [module.common]
}

module "product" {
  source                            = "./modules/product"
  pjname                            = var.pjname
  location                          = var.location
  aks_aci_subnet_cidr               = var.aks_aci_subnet_cidr
  product_db_subnet_cidr            = var.product_db_subnet_cidr
  product_db_sku                    = var.product_db_sku
  vnet_name                         = var.vnet_name
  vnet_rg_name                      = var.vnet_rg_name
  vnet_id                           = var.vnet_id
  product_db_administrator_login    = var.product_db_administrator_login
  product_db_administrator_password = var.product_db_administrator_password

  depends_on = [module.common]
}
