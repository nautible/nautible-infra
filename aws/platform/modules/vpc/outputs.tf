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
output "nat_instance_id" {
  value = var.nat_instance_type == null ? "" : module.nat_instance[0].id
}

