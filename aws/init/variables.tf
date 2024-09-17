variable "project" {
  description = "プロジェクト名称"
  # default = ""
}

variable "environment" {
  description = "環境名定義"
  default     = "dev"
}

variable "use_lock_table" {
  description = "ロックテーブル（DynamoDB）の利用有無"
  default     = true
}

# aws region 
variable "region" {
  default = "ap-northeast-1"
}
