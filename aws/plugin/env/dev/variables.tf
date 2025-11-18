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

# platform tfstate
variable "platform_tfstate" {
  description = "platform tfstate設定"
  default     = "nautible-dev-platform.tfstate"
}

locals {
  backend_config = jsondecode(file(".terraform/terraform.tfstate"))
}

variable "cluster_name" {
  description = "プラグインを導入するEKSクラスタ名"
  type        = string
  default     = "nautible-dev-cluster-v1_34"
}
# EKS
variable "eks" {
  default = {
    # [複数クラスターの運用を行わない場合は利用しない機能。]
    # clusterアップデートのblue/green運用などで複数clusterが存在する場合に、除外するcluster名を指定する。
    # 除外されたclusterのnodeへ付与するPolicyやclusterからのアクセスを許容するためのSecurity Group設定を削除するためなどに利用する。
    # 指定無しの場合は全clusterが有効。
    # excludes_cluster_names = ["nautible-dev-cluster-v1_22"]
  }
}

# EKSに追加するアドオンの設定
# https://docs.aws.amazon.com/ja_jp/eks/latest/userguide/workloads-add-ons-available-eks.html
# https://docs.aws.amazon.com/ja_jp/eks/latest/userguide/community-addons.html
variable "eks_addon" {
  description = "アドオン設定"
  type = list(object({
    addon_name                   = string
    addon_version                = string
    enable_pod_identity          = bool
    pod_identity_service_account = string
    service_policy_arns          = list(string)
    statements = optional(list(object({
      effect    = string
      actions   = list(string)
      resources = list(string)
      principals = optional(list(object({
        type        = string
        identifiers = list(string)
      })))
    })))
  }))
  default = [
    # {
    #   # EKSのタイプをNodeGroupにした場合のみ設定する
    #   addon_name                   = "aws-ebs-csi-driver"
    #   addon_version                = "v1.52.1-eksbuild.1"
    #   enable_pod_identity          = true
    #   pod_identity_service_account = "ebs-csi-controller-sa"
    #   statements                   = null
    #   service_policy_arns          = ["arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"]
    # },
    {
      addon_name                   = "amazon-cloudwatch-observability"
      addon_version                = "v4.6.0-eksbuild.1"
      enable_pod_identity          = true
      pod_identity_service_account = "cloudwatch-agent"
      statements                   = null
      service_policy_arns          = ["arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess", "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"]
    },
    {
      addon_name                   = "metrics-server"
      addon_version                = "v0.8.0-eksbuild.3"
      enable_pod_identity          = false
      pod_identity_service_account = null
      statements                   = null
      service_policy_arns          = []
    },
    {
      addon_name                   = "kube-state-metrics"
      addon_version                = "v2.17.0-eksbuild.3"
      enable_pod_identity          = false
      pod_identity_service_account = null
      statements                   = null
      service_policy_arns          = []
    },
    {
      addon_name                   = "prometheus-node-exporter"
      addon_version                = "v1.10.2-eksbuild.2"
      enable_pod_identity          = false
      pod_identity_service_account = null
      statements                   = null
      service_policy_arns          = []
    },
    {
      addon_name                   = "cert-manager"
      addon_version                = "v1.19.1-eksbuild.1"
      enable_pod_identity          = false
      pod_identity_service_account = null
      statements                   = null
      service_policy_arns          = []
    }
  ]
}

# authのvariables。authのpluginを利用する場合は値を設定する
variable "auth" {
  description = "auth設定"
  # type        = string # auth pluginを利用しない場合。
  # default     = ""     # auth pluginを利用しない場合。
  type = object({
    postgres = object({
      engine_version       = string
      instance_class       = string
      parameter_group_name = string
      storage_type         = string
      allocated_storage    = number
    }),
    namespace       = string
    service_account = string

  })
  default = {
    # postgresql variables
    postgres = {
      engine_version       = "17.4"
      instance_class       = "db.t3.micro"
      parameter_group_name = "default.postgres17"
      storage_type         = "gp3"
      allocated_storage    = 20
    },
    namespace       = "external-secrets"
    service_account = "secretstore"
  }
}

variable "kong_apigateway" {
  type    = string # kong-apigateway pluginを利用しない場合。
  default = ""     # kong-apigateway pluginを利用しない場合。
  # type = object({
  #   sqs = object({
  #     message_retention_seconds = number
  #   })
  # })
  # default = {
  #   sqs = {
  #     message_retention_seconds = 60
  #   }
  # }
}

variable "external_secrets" {
  # type    = string # external-secrets pluginを利用しない場合。
  # default = ""     # external-secrets pluginを利用しない場合。
  type = object({
    namespace       = string
    service_account = string
  })
  default = {
    namespace       = "external-secrets"
    service_account = "external-secrets"
  }

}
variable "grafana" {
  type    = string # observation pluginを利用しない場合。
  default = ""     # observation pluginを利用しない場合。
  # type    = string
  # default = "true"
}

variable "openobserve" {
  #type    = string # observation pluginを利用しない場合。
  #default = ""     # observation pluginを利用しない場合。
  type = object({
    namespace       = string
    service_account = string
  })
  default = {
    namespace       = "openobserve"
    service_account = "openobserve"
  }
}
