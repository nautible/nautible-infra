output "vpc" {
  value = {
    vpc_id              = module.vpc.vpc_id
    public_subnets      = module.vpc.private_subnets
    private_subnets     = module.vpc.private_subnets
    private_subnet_arns = module.vpc.private_subnet_arns
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
