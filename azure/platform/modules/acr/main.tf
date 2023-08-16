resource "azurerm_container_registry" "acr" {
  name                = "${var.pjname}acr"
  resource_group_name = var.rgname
  location            = var.location
  sku                 = "Standard"
  tags                = {}
}
