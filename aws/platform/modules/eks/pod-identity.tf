
resource "aws_eks_pod_identity_association" "load_balancer_association" {
  cluster_name    = var.cluster_name
  namespace       = "kube-system"
  service_account = "aws-load-balancer-controller-sa"
  role_arn        = var.albc_role_arn

  depends_on = [module.eks]
}

resource "aws_eks_pod_identity_association" "ebs_csi_driver_association" {
  cluster_name    = var.cluster_name
  namespace       = "kube-system"
  service_account = "ebs-csi-controller-sa"
  role_arn        = var.csi_driver_role_arn

  depends_on = [module.eks]
}

resource "aws_eks_pod_identity_association" "cluster_autoscaler_association" {
  cluster_name    = var.cluster_name
  namespace       = "autoscaler"
  service_account = "cluster-autoscaler-aws-cluster-autoscaler"
  role_arn        = var.autoscaler_role_arn

  depends_on = [module.eks]
}
