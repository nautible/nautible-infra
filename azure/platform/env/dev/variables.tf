# Project name
variable "pjname" {
  default = "nautibledev"
}
# location
variable "location" {
  default = "japaneast"
}

# VNET
variable "vnet" {
  description = "VNET設定"
  type = object({
    vnet_cidr = string
  })
  default = {
    # VNET cidr
    vnet_cidr = "192.0.0.0/8"
  }
}

# AKS
variable "aks" {
  description = "AKS設定"
  type = object({
    kubernetes_version                        = string
    max_pods                                  = number
    log_analytics_workspace_retention_in_days = number
    cluster_inbound_http_port_range           = string
    api_server_authorized_ip_ranges           = list(string)
    subnet = object({
      cidrs = list(string)
      names = list(string)
    })
    node = object({
      vm_size            = string
      os_disk_size_gb    = number
      max_count          = number
      min_count          = number
      node_count         = number
      availability_zones = list(string)
    })
  })
  default = {
    # kubernetes version 
    kubernetes_version = "1.27.3"
    # max pods
    max_pods = 110
    # log analytics workspace retention in days
    log_analytics_workspace_retention_in_days = 30
    # inbound http port range. e.g "80,8080-8082"
    cluster_inbound_http_port_range = "80"
    # api server authorized ip ranges
    api_server_authorized_ip_ranges = []
    subnet = {
      # cidr
      cidrs = ["192.168.0.0/16", "192.169.0.0/16"]
      # name
      names = ["aksdefaultnodesubnet", "aksacisubnet"]
    }
    node = {
      # node vm size."standard_b2s" can't deploy istio.
      vm_size = "standard_d4s_v4"
      # node os disk size gb. min size is 30
      os_disk_size_gb = 30
      # node max count
      max_count = 5
      # node min count
      min_count = 2
      # node count
      node_count = 2
      # availability zones
      availability_zones = ["1", "2"]
    }
  }
}

# staticweb
variable "static_web" {
  description = "staticweb設定"
  type = object({
    index_document     = string
    error_404_document = string
  })
  default = {
    # index document
    index_document = "index.html"
    # error 404 document. e.g 404.html
    error_404_document = ""
  }
}

# frontdoor
variable "frontdoor" {
  description = "frontdoor設定"
  type = object({
    session_affinity_enabled             = bool
    istio_ig_lb_ip                       = string
    service_api_path_pattern             = string
    access_log_storage_account_allow_ips = list(string)
  })
  default = {
    # session affinity enabled
    session_affinity_enabled = false
    # istio ingressgateway loadbalancer created
    # Istioのロードバランサーを作成後にIPを指定してください。apiのルーティングをfrontdoorに作成します。 
    # Istioのロードバランサー作成前は、nullを指定してください。
    # istio_ig_lb_ip = "20.89.84.213"
    istio_ig_lb_ip = null
    # service api path pattern for cloudfront routing to istio lb
    service_api_path_pattern = "/api/*"
    # access logのstorage accountへのアクセスを許容するIP
    access_log_storage_account_allow_ips = []
  }
}

variable "dns" {
  description = "dns設定"
  type = object({
    privatelink_keyvault_enable   = bool
    privatelink_cosmosdb_enable   = bool
    privatelink_servicebus_enable = bool
    privatelink_redis_enable      = bool
  })
  default = {
    # PrivateLinkでアクセスするリソースの有無を設定し、PrivateLink用のprivate DNSを作成します。
    # PrivateLink用のDNSはリソース毎に１つしか作成できないので、platformプロジェクトで一元管理します。
    # 利用するpluginによって利用するリソースが変わるため、利用するpluginに合わせて事前にplatformプロジェクトで管理します。
    privatelink_keyvault_enable   = true # app-ms,auth
    privatelink_cosmosdb_enable   = true # app-ms
    privatelink_servicebus_enable = true # app-ms
    privatelink_redis_enable      = true # app-ms
  }
}
