data "azuread_client_config" "current" {}
data "azurerm_subscription" "current" {}

resource "azurerm_storage_account" "azurerm_storage_account_backup" {
  name                     = var.backup_storage_account_name
  resource_group_name      = var.rgname
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "azurerm_storage_container_backup" {
  name                  = "velero"
  storage_account_name  = azurerm_storage_account.azurerm_storage_account_backup.name
  container_access_type = "private"
}

resource "azuread_application" "backup_app" {
  display_name = "${var.pjname}-backup"
  # owners       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal" "backup_app_principal" {
  application_id               = azuread_application.backup_app.application_id
  app_role_assignment_required = true
  # owners                       = [data.azuread_client_config.current.object_id]
}

resource "azurerm_role_assignment" "backup_role_contributor" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.backup_app_principal.id
}
