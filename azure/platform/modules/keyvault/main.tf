data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "keyvault_rg" {
  name     = "${var.pjname}keyvault"
  location = var.location
  tags     = {}
}

resource "azurerm_key_vault" "keyvault" {
  name                       = "${var.pjname}keyvault"
  location                   = azurerm_resource_group.keyvault_rg.location
  resource_group_name        = azurerm_resource_group.keyvault_rg.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days = 30
  purge_protection_enabled   = false

  sku_name = "standard"
  tags     = {}
}

resource "azurerm_key_vault_access_policy" "keyvault_ap" {
  key_vault_id            = azurerm_key_vault.keyvault.id
  tenant_id               = data.azurerm_client_config.current.tenant_id
  object_id               = var.nautible_service_principal_object_id
  certificate_permissions = []
  storage_permissions     = []
  key_permissions = [
    "Get", "List"
  ]

  secret_permissions = [
    "Get", "List"
  ]
}

