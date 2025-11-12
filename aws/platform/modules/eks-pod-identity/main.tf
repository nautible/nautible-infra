# EKS NodeGroup時にPodIdentity設定を追加するためのモジュール
# EKS AutoModeではデフォルトで設定されるため、本モジュールの設定は利用しません

module "load_balancer_controller_pod_identity" {
  source  = "terraform-aws-modules/eks-pod-identity/aws"
  version = "2.2.1"

  name                            = "${var.pjname}-LoadBalancerRole"
  attach_aws_lb_controller_policy = true
  aws_lb_controller_policy_name   = "${var.pjname}-LoadBalancerPolicy"
}

module "ebs_csi_driver_pod_identity" {
  source  = "terraform-aws-modules/eks-pod-identity/aws"
  version = "2.2.1"

  name                      = "${var.pjname}-EbsCsiDriverRole"
  attach_aws_ebs_csi_policy = true
  aws_ebs_csi_policy_name   = "${var.pjname}-EbsCsiDriverPolicy"

}

module "cluster_autoscaler_pod_identity" {
  source  = "terraform-aws-modules/eks-pod-identity/aws"
  version = "2.2.1"

  name = "${var.pjname}-ClusterAutoscalerRole"

  attach_cluster_autoscaler_policy = true
  cluster_autoscaler_policy_name   = "${var.pjname}-ClusterAutoscalerPolicy"
}
