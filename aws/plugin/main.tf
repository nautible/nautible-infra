module "auth" {
  source = "./modules/auth"
  count                      = try(var.auth_variables.postgres.engine_version, "") != "" ? 1 : 0
  pjname                     = var.pjname
  vpc_id                     = var.vpc_id
  region                     = var.region
  private_subnets            = var.private_subnets
  eks_node_security_group_id = var.eks_node_security_group_id
  auth_variables             = var.auth_variables
  eks_oidc_provider_arn = var.eks_oidc_provider_arn
}

module "kong-apigateway" {
  source                    = "./modules/kong-apigateway"
  count                     = try(var.kong_apigateway_variables, "") != "" ? 1 : 0
  kong_apigateway_variables = var.kong_apigateway_variables
}
