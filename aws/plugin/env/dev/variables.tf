# Project name
variable "pjname" {
  # 通常のnautible設定
  #default = "nautible-plugin-dev"
  default = "nautible-ca-plugin-dev"
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

# authのvariables。authのpluginを利用する場合は値を設定する
variable "auth" {
  description = "auth設定"
  type = object({
    postgres = object({
      engine_version       = string
      instance_class       = string
      parameter_group_name = string
      storage_type         = string
      allocated_storage    = number
    })
  })
  # default = "" # auth pluginを利用しない場合。
  default = {
    # postgresql variables
    postgres = {
      engine_version       = "14.3"
      instance_class       = "db.t3.micro"
      parameter_group_name = "default.postgres14"
      storage_type         = "gp2"
      allocated_storage    = 20
    }
  }
}

variable "kong_apigateway" {
  # default = "" # kong-apigateway pluginを利用しない場合。
  default = {
    sqs = {
      message_retention_seconds = 60
    }
  }
}

variable "backup" {
  description = "バックアップ設定"
  type = object({
    s3_bucket_name = string
  })
  default = {
    s3_bucket_name = "nautible-velero-backup"
  }
}
