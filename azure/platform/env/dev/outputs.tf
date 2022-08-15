
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

output "keyvault_private_dns_zone_id" {
  value = module.nautible_azure_platform.keyvault_private_dns_zone_id
}

output "cosmosdb_private_dns_zone_id" {
  value = module.nautible_azure_platform.cosmosdb_private_dns_zone_id
}

output "servicebus_private_dns_zone_id" {
  value = module.nautible_azure_platform.servicebus_private_dns_zone_id
}

output "redis_private_dns_zone_id" {
  value = module.nautible_azure_platform.redis_private_dns_zone_id
}
