variable "pjname" {
  default = "nautibledev"
}

variable "location" {
  default = "japaneast"
}

variable "backup_resource_group_name" {
  description = "バックアップ関連のリソースをまとめたリソースグループ"
  default     = "nautibledevbackup"
}

variable "backup_storage_account_name" {
  description = "バックアップデータ用ストレージアカウント"
  default     = "nautibledevbackup"
}

variable "backup_storage_container_name" {
  description = "バックアップデータ用コンテナ"
  default     = "nautibledevbackupcontainer"
}

