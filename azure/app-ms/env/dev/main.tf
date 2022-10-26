provider "azurerm" {
  features {} // required but empty ok
}

terraform {
  # fix folloing value
  backend "azurerm" {
    resource_group_name  = "nautibledevterraform"
    storage_account_name = "nautibledevterraformsa"
    container_name       = "nautibledevterraformcontainer"
    key                  = "nautibledevapp.tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.6.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.22.0"
    }

  }

}

module "nautible_azure_app" {
  source   = "../../"
  pjname   = var.pjname
  location = var.location
  vnet = {
    id      = data.terraform_remote_state.nautible_azure_platform.outputs.vnet.vnet_id
    name    = data.terraform_remote_state.nautible_azure_platform.outputs.vnet.vnet_name
    rg_name = data.terraform_remote_state.nautible_azure_platform.outputs.vnet.vnet_rg_name
  }
  aks = {
    subnet_ids   = data.terraform_remote_state.nautible_azure_platform.outputs.aks.subnet_ids
    subnet_cidrs = data.terraform_remote_state.nautible_azure_platform.outputs.aks.subnet_cidrs
  }
  dns = {
    keyvault_private_dns_zone_id   = data.terraform_remote_state.nautible_azure_platform.outputs.dns.keyvault_private_dns_zone_id
    cosmosdb_private_dns_zone_id   = data.terraform_remote_state.nautible_azure_platform.outputs.dns.cosmosdb_private_dns_zone_id
    servicebus_private_dns_zone_id = data.terraform_remote_state.nautible_azure_platform.outputs.dns.servicebus_private_dns_zone_id
    redis_private_dns_zone_id      = data.terraform_remote_state.nautible_azure_platform.outputs.dns.redis_private_dns_zone_id
  }
  # https://www.terraform.io/language/functions/merge#examples
  common = merge(var.common, { servicebus = merge(var.common.servicebus, { sku = var.servicebus_sku }) })
  product = merge(var.product, { db = merge(var.product.db,
  { administrator_login = var.product_db_administrator_login, administrator_password = var.product_db_administrator_password }) })
  order                                = var.order
  nautible_service_principal_object_id = data.terraform_remote_state.nautible_azure_platform.outputs.app.nautible_service_principal_object_id
  oidc                                 = merge(var.oidc, { static_web_deploy = merge(var.oidc.static_web_deploy, { storage_account_id = data.terraform_remote_state.nautible_azure_platform.outputs.static_web.storage_account_id }) })
}

data "terraform_remote_state" "nautible_azure_platform" {
  backend = "azurerm"
  config = {
    resource_group_name  = "nautibledevterraform"
    storage_account_name = "nautibledevterraformsa"
    container_name       = "nautibledevterraformcontainer"
    key                  = "nautibledevplatform.tfstate"
  }
}
