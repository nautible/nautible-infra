provider "azurerm" {
  features {} // required but empty ok
}

terraform {
  # fix folloing value
  backend "azurerm" {
    resource_group_name  = "nautibledev"
    storage_account_name = "nautibledevterraformsa"
    container_name       = "nautibledevplatformterraformcontainer"
    key                  = "nautibledevplatform.tfstate"
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.68.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.41.0"
    }

  }

}

module "nautible_azure_platform" {
  source     = "../../"
  pjname     = var.pjname
  rgname     = var.pjname # rgname = pjname
  location   = var.location
  vnet       = var.vnet
  aks        = var.aks
  static_web = var.static_web
  frontdoor  = var.frontdoor
  dns        = var.dns
}
