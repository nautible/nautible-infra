resource "azurerm_resource_group" "dns_rg" {
  name     = "${var.pjname}dns"
  location = var.location
}

resource "azurerm_private_dns_zone" "keyvault_private_dns_zone" {
  count               = var.privatelink_keyvault_enable == true ? 1: 0
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.dns_rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "keyvault_private_dns_zone_virtual_network_link" {
  count                 = var.privatelink_keyvault_enable == true ? 1: 0
  name                  = "${var.pjname}keyvault"
  resource_group_name   = azurerm_resource_group.dns_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.keyvault_private_dns_zone[0].name
  virtual_network_id    = var.vnet_id
}

resource "azurerm_private_dns_zone" "cosmosdb_private_dns_zone" {
  count               = var.privatelink_cosmosdb_enable == true ? 1: 0
  name                = "privatelink.mongo.cosmos.azure.com"
  resource_group_name = azurerm_resource_group.dns_rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "cosmosdb_private_dns_zone_virtual_network_link" {
  count                 = var.privatelink_cosmosdb_enable == true ? 1: 0
  name                  = "${var.pjname}cosmosdb"
  resource_group_name   = azurerm_resource_group.dns_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.cosmosdb_private_dns_zone[0].name
  virtual_network_id    = var.vnet_id
}

resource "azurerm_private_dns_zone" "servicebus_private_dns_zone" {
  count               = var.privatelink_servicebus_enable == true ? 1: 0
  name                = "privatelink.servicebus.windows.net"
  resource_group_name = azurerm_resource_group.dns_rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "servicebus_private_dns_zone_virtual_network_link" {
  count                 = var.privatelink_servicebus_enable == true ? 1: 0
  name                  = "${var.pjname}servicebus"
  resource_group_name   = azurerm_resource_group.dns_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.servicebus_private_dns_zone[0].name
  virtual_network_id    = var.vnet_id
}

resource "azurerm_private_dns_zone" "redis_private_dns_zone" {
  count               = var.privatelink_redis_enable == true ? 1: 0
  name                = "privatelink.redis.cache.windows.net"
  resource_group_name = azurerm_resource_group.dns_rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "redis_private_dns_zone_virtual_network_link" {
  count                 = var.privatelink_redis_enable == true ? 1: 0
  name                  = "${var.pjname}redis"
  resource_group_name   = azurerm_resource_group.dns_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.redis_private_dns_zone[0].name
  virtual_network_id    = var.vnet_id
}
