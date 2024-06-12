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
      engine_version = "7.1"
      # node type
      node_type = "cache.t4g.micro"
      # parameter group name
      parameter_group_name = "default.redis7"
      # port
      port = 6379
    }
  }
}

# Product
variable "product" {
  description = "商品DB用RDS設定"
  type = object({
    mysql = object({
      engine_version    = string
      instance_class    = string
      option_group_name = string
      storage_type      = string
      allocated_storage = number
      parameter_group = object({
        family = string
        parameters = list(object({
          name  = string
          value = string
        }))
      })
    })
  })
  default = {
    mysql = {
      engine_version    = "8.0.36"
      instance_class    = "db.t3.micro"
      option_group_name = "default:mysql-8-0"
      storage_type      = "gp2"
      allocated_storage = 5
      parameter_group = {
        family = "mysql8.0"
        parameters = [
          {
            name  = "character_set_client"
            value = "utf8mb4"
          },
          {
            name  = "character_set_connection"
            value = "utf8mb4"
          },
          {
            name  = "character_set_database"
            value = "utf8mb4"
          },
          {
            name  = "character_set_filesystem"
            value = "utf8mb4"
          },
          {
            name  = "character_set_results"
            value = "utf8mb4"
          },
          {
            name  = "character_set_server"
            value = "utf8mb4"
          },
          {
            name  = "collation_connection"
            value = "utf8mb4_general_ci"
          },
          {
            name  = "collation_server"
            value = "utf8mb4_general_ci"
          },
          {
            name  = "time_zone"
            value = "Asia/Tokyo"
          }
        ]
      }
    }
  }
}

