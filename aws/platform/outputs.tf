output "vpc" {
  value = {
    vpc_id              = module.vpc.vpc_id
    public_subnets      = module.vpc.private_subnets
    private_subnets     = module.vpc.private_subnets
    private_subnet_arns = module.vpc.private_subnet_arns
  }
}

output "eks" {
  value = { for v in module.eks : v.cluster_name =>
    {
      cluster = {
        name                      = v.cluster_name
        primary_security_group_id = v.cluster_primary_security_group_id
      }
      node = {
        role_name         = v.node_role_name
        security_group_id = v.node_security_group_id
      }
      albc = {
        role_arn            = v.albc_role_arn
        security_group_id   = v.albc_security_group_id
        security_group_name = v.albc_security_group_name
      }
      oidc = {
        provider_arn = v.oidc_provider_arn
      }
      karpenter = {
        queue_name = v.karpenter_queue
      }
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
