output "keyvault_private_dns_zone_id" {
  value = var.privatelink_keyvault_enable == true ? azurerm_private_dns_zone.keyvault_private_dns_zone[0].id : ""
}

output "cosmosdb_private_dns_zone_id" {
  value = var.privatelink_cosmosdb_enable == true ? azurerm_private_dns_zone.cosmosdb_private_dns_zone[0].id : ""
}

output "servicebus_private_dns_zone_id" {
  value = var.privatelink_cosmosdb_enable == true ? azurerm_private_dns_zone.servicebus_private_dns_zone[0].id : ""
}

output "redis_private_dns_zone_id" {
  value = var.privatelink_redis_enable == true ? azurerm_private_dns_zone.redis_private_dns_zone[0].id : ""
}
