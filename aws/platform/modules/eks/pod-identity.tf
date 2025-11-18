
resource "aws_eks_pod_identity_association" "load_balancer_association" {
  cluster_name    = var.cluster_name
  namespace       = "kube-system"
  service_account = "aws-load-balancer-controller-sa"
  role_arn        = module.load_balancer_controller_pod_identity.iam_role_arn

  depends_on = [module.eks]
}

resource "aws_eks_pod_identity_association" "cluster_autoscaler_association" {
  cluster_name    = var.cluster_name
  namespace       = "autoscaler"
  service_account = "cluster-autoscaler-aws-cluster-autoscaler"
  role_arn        = module.cluster_autoscaler_pod_identity.iam_role_arn

  depends_on = [module.eks]
}

module "load_balancer_controller_pod_identity" {
  source  = "terraform-aws-modules/eks-pod-identity/aws"
  version = "2.3.0"

  name                            = "${var.pjname}-LoadBalancerRole"
  attach_aws_lb_controller_policy = true
  aws_lb_controller_policy_name   = "${var.pjname}-LoadBalancerPolicy"

  depends_on = [module.eks]
}

module "cluster_autoscaler_pod_identity" {
  source  = "terraform-aws-modules/eks-pod-identity/aws"
  version = "2.3.0"

  name = "${var.pjname}-ClusterAutoscalerRole"

  attach_cluster_autoscaler_policy = true
  cluster_autoscaler_policy_name   = "${var.pjname}-ClusterAutoscalerPolicy"

  depends_on = [module.eks]
}