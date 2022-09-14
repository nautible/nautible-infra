output "vnet_rg_name" {
  value = module.vnet.vnet_rg_name
}

output "vnet_id" {
  value = module.vnet.vnet_id
}

output "vnet_name" {
  value = module.vnet.vnet_name
}

output "aks_subnet_ids" {
  value = module.aks.subnet_ids
}

output "aks_subnet_cidrs" {
  value = module.aks.subnet_cidrs
}

output "nautible_service_principal_object_id" {
  value = module.app.nautible_service_principal_object_id
}

output "keyvault_private_dns_zone_id" {
  value = module.dns.keyvault_private_dns_zone_id
}

output "cosmosdb_private_dns_zone_id" {
  value = module.dns.cosmosdb_private_dns_zone_id
}

output "servicebus_private_dns_zone_id" {
  value = module.dns.servicebus_private_dns_zone_id
}

output "redis_private_dns_zone_id" {
  value = module.dns.redis_private_dns_zone_id
}
