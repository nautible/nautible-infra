# Project name
variable "pjname" {
  default = "nautible-app-dev"
}
# AWS region
variable "region" {
  default = "ap-northeast-1"
}
# nautible aws platform state bucket
variable "nautible_aws_platform_state_bucket" {
  default = "nautible-dev-platform-tf-ap-northeast-1"
}
# nautible aws platform state region
variable "nautible_aws_platform_state_region" {
  default = "ap-northeast-1"
}
# nautible aws platform state key
variable "nautible_aws_platform_state_key" {
  default = "nautible-dev-platform.tfstate"
}
# auth variables。authのpluginを利用する場合は値を設定する
variable "auth_variables" {
  # default = "" # auth pluginを利用しない場合。
  default = {
    # postgresql variables
    postgres = {
      engine_version       = "14.2"
      instance_class       = "db.t3.micro"
      parameter_group_name = "default.postgres14"
      storage_type         = "gp2"
      allocated_storage    = 20
    }
  }
}

variable "kong_apigateway_variables" {
  # default = "" # kong-apigateway pluginを利用しない場合。
  default = {
    sqs = {
      message_retention_seconds = 60
    }
  }
}
