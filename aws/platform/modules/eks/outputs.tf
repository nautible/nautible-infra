output "cluster_name" {
  value = module.eks.cluster_id
}

output "cluster_primary_security_group_id" {
  value = module.eks.cluster_primary_security_group_id
}

output "node_security_group_id" {
  value = module.eks.node_security_group_id
}

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

output "albc_role_arn" {
  value = module.load_balancer_controller_irsa_role.iam_role_arn
}

output "albc_security_group_id" {
  value = module.albc_security_group.security_group_id
}
output "albc_security_group_name" {
  value = module.albc_security_group.security_group_name
}
