# AWS region
variable "region" {
  default = "ap-northeast-1"
}

variable "backup_bucket_create" {
  default = "create"
}

variable "backup_bucket_name" {
  default = "nautible-plugin-velero-ap-northeast-1"
}

variable "platform_bucket_name" {
  default = "nautible-dev-platform-tf-ap-northeast-1"
}

variable "platform_tfstate_key" {
  default = "nautible-dev-platform.tfstate"
}
