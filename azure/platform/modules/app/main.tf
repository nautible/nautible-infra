data "azuread_client_config" "current" {}
data "azuread_service_principal" "key_vault" {
  display_name = "Azure Key Vault"
}

resource "azuread_application" "app" {
  display_name = "${var.pjname}app"
  owners       = [data.azuread_client_config.current.object_id]
  api {
  }

  required_resource_access {
    resource_app_id = data.azuread_service_principal.key_vault.application_id
    dynamic "resource_access" {
      for_each = data.azuread_service_principal.key_vault.oauth2_permission_scopes
      content {
        id   = resource_access.value.id
        type = "Scope"
      }
    }
  }

  lifecycle {
    ignore_changes = [
      owners
    ]
  }

}

resource "azuread_service_principal" "app_sp" {
  application_id = azuread_application.app.application_id
}
