# Project name
variable "pjname" {
  default = "nautibledev"
}
# location
variable "location" {
  default = "japaneast"
}
# istio ingressgateway loadbalancer created
# Istioのロードバランサーを作成後にIPを指定してください。apiのルーティングをfrontdoorに作成します。 
# Istioのロードバランサー作成前は、nullを指定してください。
variable "istio_ig_lb_ip" {
  default = null
  # default = "20.89.84.213"
}
# # service api path pattern for cloudfront routing to istio lb
variable "service_api_path_pattern" {
  default = "/api/*"
}
# VPC cidr
variable "vnet_cidr" {
  default = "192.0.0.0/8"
}
# Public subnet cidr
# variable "public_subnet_cidrs" {
#   default = ["192.168.4.0/24", "192.168.5.0/24"]
# }
# Private subnet cidr
variable "subnet_cidrs" {
  default = ["192.168.0.0/16","192.169.0.0/16"]
}
# subnet name.
variable "subnet_names" {
  default = ["aksdefaultnodesubnet","aksaciprivatesubnet"]
}

# static_web index_document
variable "static_web_index_document" {
  default = "index.html"
}
# static_web index_document. e.g 404.html
variable "static_web_error_404_document" {
  default = ""
}

# aks kubernetesversion 
variable "aks_kubernetes_version" {
  default = "1.23.5"
}

# aks node vm size
# "standard_b2s" can't deploy istio.
variable "aks_node_vm_size" {
  default = "standard_d2s_v3"
}

# aks node os disk size gb
# min size is 30
variable "aks_node_os_disk_size_gb" {
  default = "30" 
}

# aks node max count
variable "aks_node_max_count" {
  default = "3"
}

# aks node min count
variable "aks_node_min_count" {
  default = "2"
}

# aks node count
variable "aks_node_count" {
  default = "2"
}

# aks max pods
variable "aks_max_pods" {
  default = 110
}

# aks node availability zones
variable "aks_node_availability_zones" {
  default = ["1", "2"]
}

# aks log analytics workspace retention in days
variable "aks_log_analytics_workspace_retention_in_days" {
  default = 30
}

# front door session affinity enabled
variable "front_door_session_affinity_enabled" {
  default = false
}

# web_http port range. e.g "80,8080-8082"
variable "web_http_port_range" {
  default = "80"
}

variable "dns" {
  default = {
    # create private dns
    privatelink_keyvault_enable = true # app-ms,auth
    privatelink_cosmosdb_enable = true # app-ms
    privatelink_redis_enable = true # app-ms
  }
}
