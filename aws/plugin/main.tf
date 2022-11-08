module "auth" {
  source                        = "./modules/auth"
  count                         = try(var.auth.postgres.engine_version, "") != "" ? 1 : 0
  pjname                        = var.pjname
  vpc_id                        = var.vpc.vpc_id
  region                        = var.region
  private_subnets               = var.vpc.private_subnets
  postgres_engine_version       = var.auth.postgres.engine_version
  postgres_instance_class       = var.auth.postgres.instance_class
  postgres_parameter_group_name = var.auth.postgres.parameter_group_name
  postgres_storage_type         = var.auth.postgres.storage_type
  postgres_allocated_storage    = var.auth.postgres.allocated_storage
  eks_node_security_group_ids   = values(var.eks).*.node.security_group_id
  eks_oidc_provider_arns        = values(var.eks).*.oidc.provider_arn
}

module "kong-apigateway" {
  source          = "./modules/kong-apigateway"
  count           = try(var.kong_apigateway, "") != "" ? 1 : 0
  kong_apigateway = var.kong_apigateway
}

module "backup" {
  source                              = "./modules/backup"
  backup_bucket_name                  = var.backup_bucket_name
  eks_cluster_name_node_role_name_map = zipmap(values(var.eks).*.cluster.name,values(var.eks).*.node.role_name)
}
