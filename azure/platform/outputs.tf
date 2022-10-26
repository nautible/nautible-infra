output "vnet" {
  value = {
    vnet_rg_name = module.vnet.vnet_rg_name
    vnet_id      = module.vnet.vnet_id
    vnet_name    = module.vnet.vnet_name
  }
}
output "aks" {
  value = {
    subnet_ids   = module.aks.subnet_ids
    subnet_cidrs = module.aks.subnet_cidrs
  }
}

output "app" {
  value = {
    nautible_service_principal_object_id = module.app.nautible_service_principal_object_id
  }
}

output "dns" {
  value = {
    keyvault_private_dns_zone_id   = module.dns.keyvault_private_dns_zone_id
    cosmosdb_private_dns_zone_id   = module.dns.cosmosdb_private_dns_zone_id
    servicebus_private_dns_zone_id = module.dns.servicebus_private_dns_zone_id
    redis_private_dns_zone_id      = module.dns.redis_private_dns_zone_id
  }
}

output "static_web" {
  value = {
    primary_web_host   = module.static_web.primary_web_host
    storage_account_id = module.static_web.storage_account_id
  }
}