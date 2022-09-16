# Project name
variable "pjname" {
  default = "nautible-plugin-dev"
}
# AWS region
variable "region" {
  default = "ap-northeast-1"
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
    # platform tfstate bucket
    bucket = "nautible-dev-platform-tf-ap-northeast-1"
    # platform tfstate region
    region = "ap-northeast-1"
    # platform tfstate key
    key = "nautible-dev-platform.tfstate"
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
      engine_version       = "14.2"
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

variable "container_scan" {
  # default = "" # kong-apigateway pluginを利用しない場合。
  default = true
}
