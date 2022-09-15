# Project name
variable "pjname" {
  default = "nautible-app-dev"
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
