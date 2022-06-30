module "auth" {
  source         = "./modules/auth"
  count          = try(var.auth_variables.postgres.version, "") != "" ? 1 : 0
  pjname         = var.pjname
  location       = var.location
  vnet_rg_name   = var.vnet_rg_name
  vnet_name      = var.vnet_name
  vnet_id        = var.vnet_id
  auth_variables = var.auth_variables
}
