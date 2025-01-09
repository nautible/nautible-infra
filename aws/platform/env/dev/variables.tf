# Project name
variable "project" {
  description = "プロジェクト名称 ex) nautible"
  # default = ""
}

variable "environment" {
  description = "環境名定義"
  default     = "dev"
}

# AWS region
variable "region" {
  default = "ap-northeast-1"
}

variable "github_organization" {
  description = "CI/CD用のGitHub Organization名"
  # default = ""
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
      desired_size               = number
      max_size                   = number
      min_size                   = number
      instance_type              = string
      ami_type                   = string
      ami_id                     = string
      enable_bootstrap_user_data = string
      pre_bootstrap_user_data    = string
      cloudinit_pre_nodeadm = list(object({
        content      = string
        content_type = optional(string)
        filename     = optional(string)
        merge_type   = optional(string)
      }))
      disk_size = number
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
        # ami_type（ami_idを指定する場合は設定不要）
        ami_type = "AL2023_x86_64_STANDARD"
        # ami_id（ami_typeを指定する場合は設定不要）
        # なお、ami_idを指定する場合、追加のuser_data指定はAMIによるので個別に対応が必要
        ami_id = ""
        # disk size
        disk_size = 20

        # pre_bootstrap_user_data（AmazonLinux2のAMI_TYPEを指定した際に利用）
        pre_bootstrap_user_data = ""
        # pre_bootstrap_user_data 記載例
        #         pre_bootstrap_user_data = <<-EOT
        # MIME-Version: 1.0
        # Content-Type: multipart/mixed; boundary="//"

        # --//
        # Content-Type: text/x-shellscript; charset="us-ascii"
        # #!/bin/bash -xe
        # /etc/eks/bootstrap.sh nautible-dev-cluster-v1_29 --use-max-pods false --kubelet-extra-args '--max-pods=110'
        # --//--
        #         EOT

        # enable bootstrap user data（AmazonLinux2のAMI_IDを指定した際に利用）
        enable_bootstrap_user_data = ""
        # enable_bootstrap_user_data 記載例
        #enable_bootstrap_user_data = "--use-max-pods false --kubelet-extra-args '--max-pods=110'"

        # cloudinit_pre_nodeadm （AmazonLinux2023のAMI_TYPEを指定した際に利用）
        # example https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/examples/eks-managed-node-group/eks-al2023.tf
        cloudinit_pre_nodeadm = [
          {
            content_type = "application/node.eks.aws"
            content      = <<-EOT
            ---
            apiVersion: node.eks.aws/v1alpha1
            kind: NodeConfig
            spec:
              kubelet:
                config:
                  shutdownGracePeriod: 30s
                  featureGates:
                    DisableKubeletCloudCredentialProviders: true
          EOT
          }
        ]
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
    oidc_provider_arn = string
    url               = string
    client_id_list    = list(string)
    thumbprint_list   = list(string)
  })
  default = {
    oidc_provider_arn = ""
    url               = "https://token.actions.githubusercontent.com"
    client_id_list    = ["sts.amazonaws.com"]
    thumbprint_list   = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
  }
}
