variable "project" {
  description = "プロジェクト名称 ex) nautible"
  # default = ""
}

variable "environment" {
  description = "環境名定義"
  default     = "dev"
}

# aws region 
variable "region" {
  default = "ap-northeast-1"
}
