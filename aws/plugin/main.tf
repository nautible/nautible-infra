module "auth" {
  source = "./modules/auth"
  count                      = try(var.auth_variables.postgres.engine_version, "") != "" ? 1 : 0
  pjname                     = var.pjname
  vpc_id                     = var.vpc_id
  private_subnets            = var.private_subnets
  eks_node_security_group_id = var.eks_node_security_group_id
  auth_variables             = var.auth_variables
}

module "kong-apigateway" {
  source                                = "./modules/kong-apigateway"
  kong_apigateway_sqs_retention_seconds = var.kong_apigateway_sqs_retention_seconds
}
