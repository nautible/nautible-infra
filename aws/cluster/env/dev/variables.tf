variable "group" {
  default  = "" // 変数宣言のみ。値は実行時に設定する。
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
        name = ""
        # version
        version = "1.27"
        # endpoint private access
        endpoint_private_access = true
        # endpoint public access
        endpoint_public_access = true
        # endpoint public access cidrs
        endpoint_public_access_cidrs = ["0.0.0.0/0"] # TODO 動的設定
        # addons
        addons = {
          # coredns version
          coredns_version = "v1.10.1-eksbuild.2"
          # vpc-cni version
          vpc_cni_version = "v1.13.3-eksbuild.1"
          # kube-proxy version
          kube_proxy_version = "v1.27.3-eksbuild.2"
          # aws-ebs-csi-driver
          ebs_csi_driver_version = "v1.20.0-eksbuild.1"
        }
      }
      # fargate namespaces
      fargate_selectors = []
      # nodegroup
      node_group = {
        # desired size
        desired_size = 1
        # max size
        max_size = 1
        # min size
        min_size = 1
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

# platform tfstate
variable "platform_tfstate" {
  description = "platform tfstate設定"
  type = object({
    bucket = string
    region = string
    key    = string
  })
  default = {
    bucket  = ""
    region  = ""
    key     = ""
  }
}