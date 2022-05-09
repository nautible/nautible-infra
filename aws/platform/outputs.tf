output "vpc_id" {
  value = module.vpc.vpc_id
}
output "public_subnets" {
  value = module.vpc.private_subnets
}
output "private_subnets" {
  value = module.vpc.private_subnets
}
output "private_subnet_arns" {
  value = module.vpc.private_subnet_arns
}

output "eks_cluster_name" {
  value = module.eks.eks_cluster_name
}

output "zone_id" {
  value = module.route53.zone_id
}

output "zone_name" {
  value = module.route53.zone_name
}

output "private_zone_id" {
  value = module.route53.private_zone_id
}

output "private_zone_name" {
  value = module.route53.private_zone_name
}