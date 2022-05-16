output "eks_cluster_name" {
  value = module.eks.cluster_id
}

output "eks_cluster_primary_security_group_id" {
  value = module.eks.cluster_primary_security_group_id
}

output "eks_node_security_group_id" {
  value = module.eks.node_security_group_id
}

output "eks_albc_role_arn" {
  value = module.load_balancer_controller_irsa_role.iam_role_arn
}

output "eks_albc_security_group_id" {
  value = module.albc_security_group.security_group_id
}
output "eks_albc_security_group_name" {
  value = module.albc_security_group.security_group_name
}
