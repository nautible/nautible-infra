data "azuread_client_config" "current" {}

resource "azuread_application" "githubactions_static_web_deploy_app" {
  display_name = "${var.pjname}-githubactions-static-web-deploy"
  owners       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal" "githubactions_static_web_deploy_app_sp" {
  application_id = azuread_application.githubactions_static_web_deploy_app.application_id
}

resource "azurerm_role_assignment" "githubactions_static_web_deploy_app_ra" {
  scope                = var.static_web_deploy_storage_account_id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.githubactions_static_web_deploy_app_sp.id
}

resource "azuread_application_federated_identity_credential" "githubactions_static_web_deploy_app_fic_branch" {
  for_each              = toset(var.static_web_deploy_github_repo_branches)
  application_object_id = azuread_application.githubactions_static_web_deploy_app.object_id
  display_name          = "${var.pjname}-githubactions-static-web-deploy-branch-${replace(each.value,"/","-")}"
  audiences             = ["api://AzureADTokenExchange"]
  issuer                = "https://token.actions.githubusercontent.com"
  subject               = "repo:${var.oidc_github_organization}/${var.static_web_deploy_github_repo_name}:ref:refs/heads/${each.value}"
}

resource "azuread_application_federated_identity_credential" "githubactions_static_web_deploy_app_fic_environment" {
  for_each              = toset(var.static_web_deploy_github_repo_environments)
  application_object_id = azuread_application.githubactions_static_web_deploy_app.object_id
  display_name          = "${var.pjname}-githubactions-static-web-deploy-env-${each.value}"
  audiences             = ["api://AzureADTokenExchange"]
  issuer                = "https://token.actions.githubusercontent.com"
  subject               = "repo:${var.oidc_github_organization}/${var.static_web_deploy_github_repo_name}:environment:${each.value}"
}
