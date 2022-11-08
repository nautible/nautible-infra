# Project name
variable "pjname" {
  # 通常のnautible設定
  #default = "nautible-app-dev"
  default = "nautible-ca-app-dev"
}
# AWS region
variable "region" {
  # 通常のnautible設定
  #default = "ap-northeast-1"
  default = "us-east-1"
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
    # 通常のnautible設定
    # platform tfstate bucket
    #bucket = "nautible-dev-platform-tf-ap-northeast-1"
    # platform tfstate region
    #region = "ap-northeast-1"
    # platform tfstate key
    #key = "nautible-dev-platform.tfstate"

    # platform tfstate bucket
    bucket = "nautible-cloudarch-dev-platform-tf-us-east-1"
    # platform tfstate region
    region = "us-east-1"
    # platform tfstate key
    key = "nautible-cloudarch-dev-platform.tfstate"
  }
}

# EKS
variable "eks" {
  default = {
    # [複数クラスターの運用を行わない場合は利用しない機能。]
    # clusterアップデートのblue/green運用などで複数clusterが存在する場合に、除外するcluster名を指定する。
    # 除外されたclusterのnodeへ付与するPolicyやclusterからのアクセスを許容するためのSecurity Group設定を削除するためなどに利用する。
    # 指定無しの場合は全clusterが有効。
    excludes_cluster_names = ["nautible-dev-cluster-v1_23"]
  }
}


# ORDER
variable "order" {
  description = "ORDER設定"
  type = object({
    elasticache = object({
      engine_version       = string
      node_type            = string
      parameter_group_name = string
      port                 = number
    })
  })
  default = {
    # elasticache
    elasticache = {
      # engine version
      engine_version = "6.x"
      # node type
      node_type = "cache.t2.micro"
      # parameter group name
      parameter_group_name = "default.redis6.x"
      # port
      port = 6379
    }
  }
}
