provider "aws" {
  region = var.region
}

terraform {
  # fix folloing value
  backend "s3" {
    bucket  = "nautible-dev-platform-tf-ap-northeast-1"
    region  = "ap-northeast-1"
    key     = "nautible-dev-platform.tfstate"
    encrypt = true
    # if you don't need to dynamodb tfstate lock, comment out this line.
    dynamodb_table = "nautible-dev-platform-tfstate-lock"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.8.0"
    }
  }
}

module "nautible_aws_platform" {
  source                                   = "../../"
  pjname                                   = var.pjname
  region                                   = var.region
  istio_ig_lb_name                         = var.istio_ig_lb_name
  service_api_path_pattern                 = var.service_api_path_pattern
  vpc_cidr                                 = var.vpc_cidr
  private_subnet_cidrs                     = var.private_subnet_cidrs
  public_subnet_cidrs                      = var.public_subnet_cidrs
  nat_instance_type                        = var.nat_instance_type
  create_iam_resources                     = var.create_iam_resources
  eks_cluster_version                      = var.eks_cluster_version
  eks_ng_desired_size                      = var.eks_ng_desired_size
  eks_ng_max_size                          = var.eks_ng_max_size
  eks_ng_min_size                          = var.eks_ng_min_size
  eks_ng_instance_type                     = var.eks_ng_instance_type
  eks_default_ami_type                     = var.eks_default_ami_type
  eks_default_disk_size                    = var.eks_default_disk_size
  eks_cluster_endpoint_private_access      = var.eks_cluster_endpoint_private_access
  eks_cluster_endpoint_public_access       = var.eks_cluster_endpoint_public_access
  eks_cluster_endpoint_public_access_cidrs = var.eks_cluster_endpoint_public_access_cidrs
  eks_cluster_addons_coredns_version       = var.eks_cluster_addons_coredns_version
  eks_cluster_addons_vpc_cni_version       = var.eks_cluster_addons_vpc_cni_version
  eks_cluster_addons_kube_proxy_version    = var.eks_cluster_addons_kube_proxy_version
  eks_fargate_selectors                    = var.eks_fargate_selectors
}
