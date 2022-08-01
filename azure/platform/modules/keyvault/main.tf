data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "keyvault_rg" {
  name     = "${var.pjname}keyvault"
  location = var.location
  tags     = {}
}
