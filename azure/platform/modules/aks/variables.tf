variable "pjname" {
  description = "プロジェクト名称 ex) nautibledev"
}
variable "rgname" {
  description = "リソースグループ名称 ex) nautibledev-rg"
}
variable "location" {
  description = "リージョン名称"
}
variable "is_private_cluster" {
  description = "Private Clusterとするかどうか"
  type = bool
  default = false  
}
variable "dns_prefix" {
  description = "DNSプレフィックス"
}
variable "enable_aci" {
  description = "ACI Connectorの有効化 短時間の急なスパイクやバッチなどのワークロードがある場合は有効化を推奨する"
  type = bool
  default = false  
}
variable "aci_subnet_name" {
  description = "ACI Connector用のサブネット名"
  type = string
  default = null
}
variable "automatic_upgrade_channel" {
  description = "AKSの自動アップグレードチャネル (none, patch（パッチバージョンを自動適用）, rapid（最新のマイナーバージョンを自動適用）, stable（最新のマイナーバージョン-1を自動適用）, node-image（最新のノードイメージを自動適用）)"
  type = string
  default = "patch"
}

variable "vnet_name" {}
variable "subnet_cidrs" {}
variable "subnet_names" {}
variable "cluster_inbound_http_port_range" {}
variable "tags" {
  type    = map(string)
  default = {}
}
variable "agents_labels" {
  type = map(string)
  default = {
    "nodepool" = "defaultnodepool"
  }
}

variable "agents_tags" {
  type = map(string)
  default = {
    "Agent" = "defaultnodepoolagent"
  }
}
variable "kubernetes_version" {}
variable "node_vm_size" {}
variable "node_os_disk_size_gb" {}
variable "node_max_count" {}
variable "node_min_count" {}
variable "node_count" {}
variable "node_availability_zones" {}
variable "max_pods" {}
variable "log_analytics_workspace_retention_in_days" {}
variable "api_server_authorized_ip_ranges" {}
variable "acr_id" {}

variable "provisioning_mode" {
  description = "プロビジョニングモード"
  type        = string
  default     = "Manual" # "Auto" or "Manual"
}
variable "enable_service_mesh" {
  description = "サービスメッシュ（Istio）の有効化"
  type = bool
  default = false
}
variable "revisions" {
  description = "Istioのリビジョン"
  type        = list(string)
  default     = []
}

variable "sku_tier" {
  description = "AKSのSKU Tier （Free or Standard or Premium） ref: https://learn.microsoft.com/ja-jp/azure/aks/free-standard-pricing-tiers"
  type        = string
  default     = "Free"
}
