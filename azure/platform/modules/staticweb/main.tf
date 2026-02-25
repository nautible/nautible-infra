resource "azurerm_storage_account" "static_web_sa" {
  name                     = "${var.rgname}staticweb"
  resource_group_name      = var.rgname
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = {}
}

resource "azurerm_storage_account_static_website" "static_web" {
  storage_account_id = azurerm_storage_account.static_web_sa.id
  index_document     = var.static_web_index_document
  error_404_document = var.static_web_error_404_document != "" ? var.static_web_error_404_document : null
}
