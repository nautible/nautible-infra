provider "azurerm" {
  features {} // required but empty ok
}
resource "azurerm_resource_group" "azurerm_resource_group_terraform" {
  name     = var.terraform_resource_group_name
  location = var.location
}

resource "azurerm_storage_account" "azurerm_storage_account_terraform" {
  name                     = var.terraform_storage_account_name
  resource_group_name      = azurerm_resource_group.azurerm_resource_group_terraform.name
  location                 = azurerm_resource_group.azurerm_resource_group_terraform.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "azurerm_storage_container_tfstate" {
  name                  = var.terraform_tfstate_storage_container_name
  storage_account_name  = azurerm_storage_account.azurerm_storage_account_terraform.name
  container_access_type = "private"
}
