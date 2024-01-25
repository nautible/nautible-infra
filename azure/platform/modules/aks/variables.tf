variable "pjname" {}
variable "rgname" {}
variable "location" {}
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
