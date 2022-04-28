output "eks_cluster_name" {
  value = module.eks.cluster_id
}

output "eks_cluster_primary_security_group_id" {
  value = module.eks.cluster_primary_security_group_id
}

output "eks_node_security_group_id" {
  value = module.eks.node_security_group_id
}


