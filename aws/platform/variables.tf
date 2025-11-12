variable "project" {}
variable "environment" {}
variable "region" {}
variable "create_iam_resources" {}
variable "vpc" {}
variable "eks_nodegroup" {}
variable "eks_automode" {}
variable "cloudfront" {}
variable "oidc" {}
variable "github_organization" {}
variable "eks_mode" {}

locals {
  pjname = "${var.project}-${var.environment}"
  
  # クラスター名のリストを動的に生成（automode優先）
  eks_cluster_names = var.eks_mode == "automode" ? var.eks_automode.*.cluster.name : (
    var.eks_mode == "nodegroup" ? var.eks_nodegroup.*.cluster.name : []
  )
}
