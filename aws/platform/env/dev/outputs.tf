output "pjname" {
  value = var.pjname
}

output "vpc_id" {
  value = module.nautible_aws_platform.vpc_id
}

output "public_subnets" {
  value = module.nautible_aws_platform.public_subnets
}

output "private_subnets" {
  value = module.nautible_aws_platform.private_subnets
}

output "private_subnet_arns" {
  value = module.nautible_aws_platform.private_subnet_arns
}

output "eks_cluster_name" {
  value = module.nautible_aws_platform.eks_cluster_name
}

output "eks_cluster_primary_security_group_id" {
  value = module.nautible_aws_platform.eks_cluster_primary_security_group_id
}

output "eks_node_security_group_id" {
  value = module.nautible_aws_platform.eks_node_security_group_id
}

output "zone_id" {
  value = module.nautible_aws_platform.zone_id
}

output "zone_name" {
  value = module.nautible_aws_platform.zone_name
}

output "private_zone_id" {
  value = module.nautible_aws_platform.private_zone_id
}

output "private_zone_name" {
  value = module.nautible_aws_platform.private_zone_name
}