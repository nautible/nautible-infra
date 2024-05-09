# Project name
variable "pjname" {
  default = "nautible-dev"
}
# AWS region
variable "region" {
  default = "ap-northeast-1"
}
# create IAM resources(user,Role) or not
variable "create_iam_resources" {
  default = true
}
# VPC
variable "vpc" {
  description = "VPC設定"
  type = object({
    vpc_cidr             = string
    public_subnet_cidrs  = list(string)
    private_subnet_cidrs = list(string)
    nat_instance_type    = string
  })
  default = {
    # VPC cidr
    vpc_cidr = "192.168.0.0/16"
    # Public subnet cidr
    public_subnet_cidrs = ["192.168.4.0/24", "192.168.5.0/24"]
    # Private subnet cidr
    private_subnet_cidrs = ["192.168.1.0/24", "192.168.2.0/24"]
    # デフォルト（NAT-instance typeを指定しない場合は）はNATGatewayを作成。
    # NAT-instance typeを指定した場合はNATInstanceを作成。
    nat_instance_type = null
    #nat_instance_type = "t3.small"
  }
}

# EKS
variable "eks" {
  description = "EKS設定"
  type = list(object({
    cluster = object({
      name                         = string
      version                      = string
      endpoint_private_access      = bool
      endpoint_public_access       = bool
      endpoint_public_access_cidrs = list(string)
      addons = object({
        coredns_version        = string
        vpc_cni_version        = string
        kube_proxy_version     = string
        ebs_csi_driver_version = string
      })
    })
    fargate_selectors = list(object({
      namespace = string
      labels = object({
        nodetype = string
      })
    }))
    node_group = object({
      desired_size  = number
      max_size      = number
      min_size      = number
      instance_type = string
      ami_type      = string
      disk_size     = number
    })
    albc_security_group_cloudfront_prefix_list_id = string
  }))

  default = [
    {
      # cluster
      cluster = {
        # name
        name = "nautible-dev-cluster-v1_29"
        # version
        version = "1.29"
        # endpoint private access
        endpoint_private_access = true
        # endpoint public access
        endpoint_public_access = true
        # endpoint public access cidrs
        endpoint_public_access_cidrs = ["0.0.0.0/0"]
        # addons
        addons = {
          # coredns version
          coredns_version = "v1.10.1-eksbuild.7"
          # vpc-cni version
          vpc_cni_version = "v1.16.2-eksbuild.1"
          # kube-proxy version
          kube_proxy_version = "v1.28.4-eksbuild.4"
          # aws-ebs-csi-driver
          ebs_csi_driver_version = "v1.27.0-eksbuild.1"
        }
      }
      # fargate namespaces
      fargate_selectors = [
        {
          namespace = "nautible-app-ms"
          labels = {
            nodetype = "fargate"
          }
        }
      ]
      # nodegroup
      node_group = {
        # desired size
        desired_size = 3
        # max size
        max_size = 5
        # min size
        min_size = 3
        # instance type
        instance_type = "t3.medium"
        # ami type
        ami_type = "AL2_x86_64"
        # disk size
        disk_size = 16
      }
      # AWS LoadBalancerControlelr security group cloudfront prefix list id
      albc_security_group_cloudfront_prefix_list_id = "pl-58a04531"
    }
  ]
}

# Cloudfront
variable "cloudfront" {
  description = "Cloudfront設定"
  type = object({
    origin_dns_name          = string
    service_api_path_pattern = string
  })
  default = {
    # cloudfront origin name
    # AWS LoadBalancer Controller dns name
    # AWS LoadBalancer Controllerを作成後にdns名を指定してください。cloudfrontを作成し、s3とAWS LoadBalancer Controllerへルーティングします。 
    # AWS LoadBalancer Controller作成前は、ブランクを指定してください（cloudfrontの作成はスキップ）。
    # cloudfront_origin_dns_name = "k8s-nautiblealbingres-1234567890-0123456789.ap-northeast-1.elb.amazonaws.com"
    origin_dns_name = ""
    # service api path pattern for cloudfront routing to istio lb
    service_api_path_pattern = "api/*"
  }
}

# OIDC Setting
variable "oidc" {
  description = "OIDC用設定"
  type = object({
    # 既存のoidc providerを利用する場合はarnを指定する
    oidc_provider_arn   = string
    url                 = string
    github_organization = string
    client_id_list      = list(string)
    thumbprint_list     = list(string)
  })
  default = {
    oidc_provider_arn   = ""
    url                 = "https://token.actions.githubusercontent.com"
    github_organization = "nautible"
    client_id_list      = ["sts.amazonaws.com"]
    thumbprint_list     = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
  }
}
