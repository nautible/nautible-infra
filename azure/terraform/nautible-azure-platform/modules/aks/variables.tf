variable "pjname" {}
variable "location" {}
variable "vnet_subnet_id" {}
variable "aci_subnet_id" {}
variable "aci_subnet_name" {}
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
variable "aks_kubernetes_version" {}
variable "aks_node_vm_size" {}
variable "aks_node_os_disk_size_gb" {}
variable "aks_node_max_count" {}
variable "aks_node_min_count" {}
variable "aks_node_count" {}
variable "aks_node_availability_zones" {}
variable "aks_max_pods" {}
variable "aks_log_analytics_workspace_retention_in_days" {}
variable "acr_id" {}
