module "common" {
  source                                 = "./modules/common"
  pjname                                 = var.pjname
  location                               = var.location
  vnet_id                                = var.vnet.id
  vnet_rg_name                           = var.vnet.rg_name
  aks_subnet_ids                         = var.aks.subnet_ids
  servicebus_sku                         = var.common.servicebus.sku
  servicebus_capacity                    = var.common.servicebus.capacity
  cosmosdb_public_network_access_enabled = var.common.cosmosdb.public_network_access_enabled
  cosmosdb_enable_free_tier              = var.common.cosmosdb.enable_free_tier
  nautible_service_principal_object_id   = var.nautible_service_principal_object_id
  keyvault_private_dns_zone_id           = var.dns.keyvault_private_dns_zone_id
  cosmosdb_private_dns_zone_id           = var.dns.cosmosdb_private_dns_zone_id
  servicebus_private_dns_zone_id         = var.dns.servicebus_private_dns_zone_id
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
  servicebus_max_delivery_count    = var.common.servicebus.max_delivery_count
  servicebus_max_size_in_megabytes = var.common.servicebus.max_size_in_megabytes
  servicebus_namespace_id          = module.common.servicebus_namespace_id
  depends_on                       = [module.common]
}

module "order" {
  source                           = "./modules/order"
  pjname                           = var.pjname
  location                         = var.location
  aks_subnet_ids                   = var.aks.subnet_ids
  vnet_id                          = var.vnet.id
  vnet_rg_name                     = var.vnet.rg_name
  order_redis_capacity             = var.order.redis.capacity
  order_redis_family               = var.order.redis.family
  order_redis_sku                  = var.order.redis.sku
  servicebus_max_delivery_count    = var.common.servicebus.max_delivery_count
  servicebus_max_size_in_megabytes = var.common.servicebus.max_size_in_megabytes
  servicebus_namespace_id          = module.common.servicebus_namespace_id
  redis_private_dns_zone_id        = var.dns.redis_private_dns_zone_id

  depends_on = [module.common]
}

module "payment" {
  source                           = "./modules/payment"
  pjname                           = var.pjname
  location                         = var.location
  servicebus_max_delivery_count    = var.common.servicebus.max_delivery_count
  servicebus_max_size_in_megabytes = var.common.servicebus.max_size_in_megabytes
  servicebus_namespace_id          = module.common.servicebus_namespace_id

  depends_on = [module.common]
}

module "product" {
  source                            = "./modules/product"
  pjname                            = var.pjname
  location                          = var.location
  aks_aci_subnet_cidr               = var.aks.subnet_cidrs[1]
  product_db_subnet_cidr            = var.product.db.subnet_cidr
  product_db_sku                    = var.product.db.sku
  vnet_name                         = var.vnet.name
  vnet_rg_name                      = var.vnet.rg_name
  vnet_id                           = var.vnet.id
  product_db_administrator_login    = var.product.db.administrator_login
  product_db_administrator_password = var.product.db.administrator_password

  depends_on = [module.common]
}

module "oidc" {
  source                                     = "./modules/oidc"
  pjname                                     = var.pjname
  oidc_github_organization                   = var.oidc.github_organization
  static_web_deploy_storage_account_id       = var.oidc.static_web_deploy.storage_account_id 
  static_web_deploy_github_repo_name         = var.oidc.static_web_deploy.github_repo.name
  static_web_deploy_github_repo_branches     = var.oidc.static_web_deploy.github_repo.branches
  static_web_deploy_github_repo_environments = var.oidc.static_web_deploy.github_repo.environments
  acr_id                                     = var.acr.acr_id
  acr_access                                 = var.oidc.acr_access
}