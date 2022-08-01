output "vnet_rg_name" {
  value = module.vnet.vnet_rg_name
}

output "vnet_id" {
  value = module.vnet.vnet_id
}

output "vnet_name" {
  value = module.vnet.vnet_name
}

output "subnet_ids" {
  value = module.vnet.subnet_ids
}

output "aks_aci_subnet_cidr" {
  value = var.subnet_cidrs[1]
}

output "nautible_service_principal_object_id" {
  value = module.app.nautible_service_principal_object_id
}

output "keyvault_rg" {
  value = module.keyvault.keyvault_rg
}
