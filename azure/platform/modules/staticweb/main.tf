resource "azurerm_storage_account" "static_web_sa" {
  name                     = "${var.rgname}staticweb"
  resource_group_name      = var.rgname
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  dynamic "static_website" {
    for_each = var.static_web_error_404_document == "" ? ["true"] : []
    content {
      index_document = var.static_web_index_document
    }
  }
  dynamic "static_website" {
    for_each = var.static_web_error_404_document != "" ? ["true"] : []
    content {
      index_document     = var.static_web_index_document
      error_404_document = var.static_web_error_404_document
    }
  }
  tags = {}
}
