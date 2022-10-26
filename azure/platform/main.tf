module "vnet" {
  source    = "./modules/vnet"
  pjname    = var.pjname
  location  = var.location
  vnet_cidr = var.vnet.vnet_cidr
}

module "app" {
  source   = "./modules/app"
  pjname   = var.pjname
  location = var.location
}

module "static_web" {
  source                        = "./modules/staticweb"
  pjname                        = var.pjname
  location                      = var.location
  static_web_index_document     = var.static_web.index_document
  static_web_error_404_document = var.static_web.error_404_document
}

module "acr" {
  source   = "./modules/acr"
  pjname   = var.pjname
  location = var.location
}

module "aks" {
  source                                    = "./modules/aks"
  pjname                                    = var.pjname
  location                                  = var.location
  vnet_rg_name                              = module.vnet.vnet_rg_name
  vnet_name                                 = module.vnet.vnet_name
  subnet_cidrs                              = var.aks.subnet.cidrs
  subnet_names                              = var.aks.subnet.names
  cluster_inbound_http_port_range           = var.aks.cluster_inbound_http_port_range
  kubernetes_version                        = var.aks.kubernetes_version
  node_vm_size                              = var.aks.node.vm_size
  node_os_disk_size_gb                      = var.aks.node.os_disk_size_gb
  node_max_count                            = var.aks.node.max_count
  node_min_count                            = var.aks.node.min_count
  node_count                                = var.aks.node.node_count
  node_availability_zones                   = var.aks.node.availability_zones
  max_pods                                  = var.aks.max_pods
  log_analytics_workspace_retention_in_days = var.aks.log_analytics_workspace_retention_in_days
  api_server_authorized_ip_ranges           = var.aks.api_server_authorized_ip_ranges
  acr_id                                    = module.acr.acr_id
}

module "front_door" {
  source                               = "./modules/frontdoor"
  pjname                               = var.pjname
  location                             = var.location
  front_door_session_affinity_enabled  = var.frontdoor.session_affinity_enabled
  static_web_primary_web_host          = module.static_web.primary_web_host
  istio_ig_lb_ip                       = var.frontdoor.istio_ig_lb_ip
  service_api_path_pattern             = var.frontdoor.service_api_path_pattern
  access_log_storage_account_allow_ips = var.frontdoor.access_log_storage_account_allow_ips
}

module "dns" {
  source                        = "./modules/dns"
  pjname                        = var.pjname
  location                      = var.location
  vnet_id                       = module.vnet.vnet_id
  privatelink_keyvault_enable   = var.dns.privatelink_keyvault_enable
  privatelink_cosmosdb_enable   = var.dns.privatelink_cosmosdb_enable
  privatelink_servicebus_enable = var.dns.privatelink_servicebus_enable
  privatelink_redis_enable      = var.dns.privatelink_redis_enable
}