module "auth" {
  source                        = "./modules/auth"
  count                         = try(var.auth, "") != "" ? 1 : 0
  pjname                        = local.pjname
  vpc_id                        = var.vpc.vpc_id
  region                        = var.region
  private_subnets               = var.vpc.private_subnets
  postgres_engine_version       = var.auth.postgres.engine_version
  postgres_instance_class       = var.auth.postgres.instance_class
  postgres_parameter_group_name = var.auth.postgres.parameter_group_name
  postgres_storage_type         = var.auth.postgres.storage_type
  postgres_allocated_storage    = var.auth.postgres.allocated_storage
  eks_node_security_group_ids   = values(var.eks).*.node.security_group_id
  #  eks_oidc_provider_arns        = values(var.eks).*.oidc.provider_arn
  eks_cluster_name = values(var.eks).*.cluster.name
  namespace        = var.auth.namespace
  service_account  = var.auth.service_account
}

module "external_secrets" {
  source           = "./modules/external-secrets"
  count            = try(var.external_secrets, "") != "" ? 1 : 0
  pjname           = local.pjname
  region           = var.region
  eks_cluster_name = values(var.eks).*.cluster.name
  namespace        = var.external_secrets.namespace
}

module "kong_apigateway" {
  source                    = "./modules/kong-apigateway"
  count                     = try(var.kong_apigateway, "") != "" ? 1 : 0
  message_retention_seconds = var.kong_apigateway.sqs.message_retention_seconds
}

module "observation" {
  source                 = "./modules/observation"
  count                  = try(var.observation, "") != "" ? 1 : 0
  pjname                 = local.pjname
  region                 = var.region
  eks_oidc_provider_arns = values(var.eks).*.oidc.provider_arn
  oidc                   = substr(values(var.eks)[0].oidc.provider_arn, 40, -1)
}
