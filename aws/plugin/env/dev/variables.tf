# Project name
variable "project" {
  description = "プロジェクト名称 ex) nautible"
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
  default = "nautible-dev-platform.tfstate"
}

locals {
  backend_config = jsondecode(file(".terraform/terraform.tfstate"))
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
    })
  })
  default = {
    # postgresql variables
    postgres = {
      engine_version       = "16.3"
      instance_class       = "db.t3.micro"
      parameter_group_name = "default.postgres16"
      storage_type         = "gp2"
      allocated_storage    = 20
    }
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

variable "observation" {
  type    = string # observation pluginを利用しない場合。
  default = ""     # observation pluginを利用しない場合。
  # type    = string
  # default = "true"
}
