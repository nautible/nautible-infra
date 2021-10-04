module "vnet" {
  source               = "./modules/vnet"
  pjname               = var.pjname
  location             = var.location
  vnet_cidr            = var.vnet_cidr
  subnet_cidrs         = var.subnet_cidrs
  subnet_names         = var.subnet_names
  web_http_port_range  = var.web_http_port_range
}

module "app" {
  source   = "./modules/app"
  pjname   = var.pjname
  location = var.location
}

module "keyvault" {
  source                               = "./modules/keyvault"
  pjname                               = var.pjname
  location                             = var.location
  nautible_service_principal_object_id = module.app.nautible_service_principal_object_id
}

module "static_web" {
  source                        = "./modules/staticweb"
  pjname                        = var.pjname
  location                      = var.location
  static_web_index_document     = var.static_web_index_document
  static_web_error_404_document = var.static_web_error_404_document
}

module "acr" {
  source   = "./modules/acr"
  pjname   = var.pjname
  location = var.location
}

module "aks" {
  source                                        = "./modules/aks"
  pjname                                        = var.pjname
  location                                      = var.location
  vnet_subnet_id                                = module.vnet.subnet_ids[0]
  aci_subnet_id                                 = module.vnet.subnet_ids[1]
  aci_subnet_name                               = var.subnet_names[1]
  aks_kubernetes_version                        = var.aks_kubernetes_version
  aks_node_vm_size                              = var.aks_node_vm_size
  aks_node_os_disk_size_gb                      = var.aks_node_os_disk_size_gb
  aks_node_max_count                            = var.aks_node_max_count
  aks_node_min_count                            = var.aks_node_min_count
  aks_node_count                                = var.aks_node_count
  aks_node_availability_zones                   = var.aks_node_availability_zones
  aks_max_pods                                  = var.aks_max_pods
  aks_log_analytics_workspace_retention_in_days = var.aks_log_analytics_workspace_retention_in_days
  acr_id                                        = module.acr.acr_id
}

module "front_door" {
  source                              = "./modules/frontdoor"
  pjname                              = var.pjname
  location                            = var.location
  front_door_session_affinity_enabled = var.front_door_session_affinity_enabled
  static_web_primary_web_host         = module.static_web.static_web_primary_web_host
  istio_ig_lb_ip                      = var.istio_ig_lb_ip
  service_api_path_pattern            = var.service_api_path_pattern
}
