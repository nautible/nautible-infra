
output "vnet_rg_name" {
  value = module.nautible_azure_platform.vnet_rg_name
}

output "vnet_id" {
  value = module.nautible_azure_platform.vnet_id
}

output "vnet_name" {
  value = module.nautible_azure_platform.vnet_name
}

output "subnet_ids" {
  value = module.nautible_azure_platform.subnet_ids
}

output "aks_aci_subnet_cidr" {
  value = module.nautible_azure_platform.aks_aci_subnet_cidr
}

output "nautible_service_principal_object_id" {
  value = module.nautible_azure_platform.nautible_service_principal_object_id
}
