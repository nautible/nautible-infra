module "auth" {
  source                               = "./modules/auth"
  count                                = try(var.auth_variables.postgres.version, "") != "" ? 1 : 0
  pjname                               = var.pjname
  location                             = var.location
  vnet_rg_name                         = var.vnet_rg_name
  subnet_ids                           = var.subnet_ids
  vnet_name                            = var.vnet_name
  vnet_id                              = var.vnet_id
  auth_variables                       = var.auth_variables
  nautible_service_principal_object_id = var.nautible_service_principal_object_id
  keyvault_private_dns_zone_id         = var.keyvault_private_dns_zone_id
  auth_postgres_administrator_login    = var.auth_postgres_administrator_login
  auth_postgres_administrator_password = var.auth_postgres_administrator_password
}
