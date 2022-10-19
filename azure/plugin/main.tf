module "auth" {
  source                               = "./modules/auth"
  count                                = try(var.auth.postgres.version, "") != "" ? 1 : 0
  pjname                               = var.pjname
  location                             = var.location
  vnet_id                              = var.vnet.id
  vnet_name                            = var.vnet.name
  vnet_rg_name                         = var.vnet.rg_name
  subnet_ids                           = var.aks.subnet_ids
  postgres_version                     = var.auth.postgres.version
  postgres_sku_name                    = var.auth.postgres.sku_name
  postgres_storage_mb                  = var.auth.postgres.storage_mb
  postgres_backup_retention_days       = var.auth.postgres.backup_retention_days
  postgres_subnet_cidr                 = var.auth.postgres.subnet_cidr
  postgres_subnet_name                 = var.auth.postgres.subnet_name
  postgres_zone                        = var.auth.postgres.zone
  postgres_administrator_login         = var.auth.postgres.administrator_login
  postgres_administrator_password      = var.auth.postgres.administrator_password
  nautible_service_principal_object_id = var.nautible_service_principal_object_id
  keyvault_private_dns_zone_id         = var.dns.keyvault_private_dns_zone_id
}
