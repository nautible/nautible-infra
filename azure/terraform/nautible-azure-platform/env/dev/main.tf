provider "azurerm" {
  features {} // required but empty ok
}

terraform {
  # fix folloing value
  backend "azurerm" {
    resource_group_name  = "nautibledevterraform"
    storage_account_name = "nautibledevterraformsa"
    container_name       = "nautibledevterraformcontainer"
    key                  = "nautibledevplatform.tfstate"
  }
}

module "nautible_azure_platform" {
  source   = "../../"
  pjname   = var.pjname
  location = var.location
  vnet_cidr                                     = var.vnet_cidr
  subnet_cidrs                                  = var.subnet_cidrs
  subnet_names                                  = var.subnet_names
  static_web_index_document                     = var.static_web_index_document
  static_web_error_404_document                 = var.static_web_error_404_document
  aks_kubernetes_version                        = var.aks_kubernetes_version
  aks_node_vm_size                              = var.aks_node_vm_size
  aks_node_os_disk_size_gb                      = var.aks_node_os_disk_size_gb
  aks_node_max_count                            = var.aks_node_max_count
  aks_node_min_count                            = var.aks_node_min_count
  aks_node_count                                = var.aks_node_count
  aks_node_availability_zones                   = var.aks_node_availability_zones
  aks_max_pods                                  = var.aks_max_pods
  aks_log_analytics_workspace_retention_in_days = var.aks_log_analytics_workspace_retention_in_days
  front_door_session_affinity_enabled           = var.front_door_session_affinity_enabled
  istio_ig_lb_ip                                = var.istio_ig_lb_ip
  service_api_path_pattern                      = var.service_api_path_pattern
  web_http_port_range                           = var.web_http_port_range
}
