module "auth" {
  source                        = "./modules/auth"
  count                         = try(var.auth.postgres.engine_version, "") != "" ? 1 : 0
  pjname                        = var.pjname
  vpc_id                        = var.vpc.vpc_id
  region                        = var.region
  private_subnets               = var.vpc.private_subnets
  eks_node_security_group_id    = var.eks.node_security_group_id
  postgres_engine_version       = var.auth.postgres.engine_version
  postgres_instance_class       = var.auth.postgres.instance_class
  postgres_parameter_group_name = var.auth.postgres.parameter_group_name
  postgres_storage_type         = var.auth.postgres.storage_type
  postgres_allocated_storage    = var.auth.postgres.allocated_storage
  eks_oidc_provider_arn         = var.eks.oidc_provider_arn
}

module "kong-apigateway" {
  source          = "./modules/kong-apigateway"
  count           = try(var.kong_apigateway, "") != "" ? 1 : 0
  kong_apigateway = var.kong_apigateway
}

module "container-scan" {
  source                = "./modules/container-scan"
  count                 = try(var.container_scan, "") != "" ? 1 : 0
  pjname                = var.pjname
  region                = var.region
  eks_oidc_provider_arn = var.eks.oidc_provider_arn
}
