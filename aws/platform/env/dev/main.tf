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
}

module "nautible_aws_platform" {
  source                   = "../../"
  pjname                   = var.pjname
  region                   = var.region
  istio_ig_lb_name         = var.istio_ig_lb_name
  service_api_path_pattern = var.service_api_path_pattern
  vpc_cidr                 = var.vpc_cidr
  private_subnet_cidrs     = var.private_subnet_cidrs
  public_subnet_cidrs      = var.public_subnet_cidrs
  nat_instance_type        = var.nat_instance_type
  create_iam_resources     = var.create_iam_resources
  eks_cluster_version      = var.eks_cluster_version
  eks_ng_desired_capacity  = var.eks_ng_desired_capacity
  eks_ng_max_capacity      = var.eks_ng_max_capacity
  eks_ng_min_capacity      = var.eks_ng_min_capacity
  eks_ng_instance_type     = var.eks_ng_instance_type
  eks_default_ami_type     = var.eks_default_ami_type
  eks_default_disk_size    = var.eks_default_disk_size
}
