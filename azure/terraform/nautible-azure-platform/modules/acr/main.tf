resource "azurerm_resource_group" "acr_rg" {
  name     = "${var.pjname}acr"
  location = var.location
  tags     = {}
}

resource "azurerm_container_registry" "acr" {
  name                = "${var.pjname}acr"
  resource_group_name = azurerm_resource_group.acr_rg.name
  location            = azurerm_resource_group.acr_rg.location
  sku                 = "Standard"
  # georeplications {
  #   location = "japanwest"
  # }
  # georeplications {
  #   location = "japaneast"
  # }
  tags = {}
}