output "primary_web_host" {
  value = azurerm_storage_account.static_web_sa.primary_web_host
}

output "storage_account_id" {
  value = azurerm_storage_account.static_web_sa.id
}