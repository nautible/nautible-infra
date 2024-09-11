output "albc_role_arn" {
  value = module.load_balancer_controller_pod_identity.iam_role_arn
}

output "csi_driver_role_arn" {
  value = module.ebs_csi_driver_pod_identity.iam_role_arn
}

output "autoscaler_role_arn" {
  value = module.cluster_autoscaler_pod_identity.iam_role_arn
}
