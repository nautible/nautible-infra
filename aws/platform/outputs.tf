output "vpc" {
  value = {
    vpc_id              = module.vpc.vpc_id
    public_subnets      = module.vpc.private_subnets
    private_subnets     = module.vpc.private_subnets
    private_subnet_arns = module.vpc.private_subnet_arns
  }
}

output "eks" {
  value = {
    cluster = {
      name                      = module.eks.cluster_name
      primary_security_group_id = module.eks.cluster_primary_security_group_id
    }
    node = {
      security_group_id = module.eks.node_security_group_id
    }
    albc = {
      role_arn            = module.eks.albc_role_arn
      security_group_id   = module.eks.albc_security_group_id
      security_group_name = module.eks.albc_security_group_name
    }
    oidc = {
      provider_arn = module.eks.oidc_provider_arn
    }
  }
}

output "route53" {
  value = {
    zone_id           = module.route53.zone_id
    zone_name         = module.route53.zone_name
    private_zone_id   = module.route53.private_zone_id
    private_zone_name = module.route53.private_zone_name
  }
}
