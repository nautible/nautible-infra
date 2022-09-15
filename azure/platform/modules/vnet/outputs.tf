output "vnet_rg_name" {
  value = azurerm_resource_group.vnet_rg.name
}

output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  value = azurerm_virtual_network.vnet.name
}
