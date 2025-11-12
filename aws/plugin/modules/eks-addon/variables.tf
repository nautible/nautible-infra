variable "region" {
  description = "AWSリージョン"
  type        = string
}

variable "cluster_name" {
  description = "EKSクラスターの名前"
  type        = string
}

variable "name" {
  description = "EKSアドオンの名前"
  type        = string
}

variable "addon_version" {
  description = "EKSアドオンのバージョン"
  type        = string
}

variable "resolve_conflicts_on_create" {
  description = "アドオン作成時の競合解決方法 NONE|OVERWRITE"
  type        = string
  default     = "OVERWRITE"
}

variable "resolve_conflicts_on_update" {
  description = "アドオン更新時の競合解決方法 NONE|PRESERVE|OVERWRITE"
  type        = string
  default     = "OVERWRITE"
}

variable "configuration_values" {
  description = "EKSアドオンの設定値"
  type        = string
  default     = ""
}

variable "enable_pod_identity" {
  description = "PodIdentityの利用設定 AWSリソースにアクセスするアドオンはtrue"
  type        = bool
}

variable "pod_identity_service_account" {
  description = "PodIdentityに関連付けるサービスアカウントの名前 enable_pod_identityがtrueの場合に必要"
  type        = string
  default     = ""
}

variable "service_policy_arns" {
  description = "サービスポリシーのARN"
  type        = list(string)
}

variable "tags" {
  description = "リソースに付与するタグ"
  type        = map(string)
  default     = {}
}