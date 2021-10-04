resource "azurerm_resource_group" "aks_rg" {
  name     = "${var.pjname}aks"
  location = var.location
}
# don't use Azure/terraform-azurerm-aks , because
# can't set role_based_access_control = true && azure_active_directory = false

resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = "${var.pjname}aks"
  kubernetes_version  = var.aks_kubernetes_version
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  dns_prefix          = var.pjname

  default_node_pool {
    orchestrator_version  = var.aks_kubernetes_version
    name                  = "agentpool"
    vm_size               = var.aks_node_vm_size
    os_disk_size_gb       = var.aks_node_os_disk_size_gb
    vnet_subnet_id        = var.vnet_subnet_id
    enable_auto_scaling   = true
    max_count             = var.aks_node_max_count
    min_count             = var.aks_node_min_count
    node_count            = var.aks_node_count
    enable_node_public_ip = false
    availability_zones    = var.aks_node_availability_zones
    node_labels           = { "nodepool" = "defaultnodepool" }
    tags                  = merge(var.tags, { "Agent" = "defaultnodepoolagent" })
    max_pods              = var.aks_max_pods

  }

  identity {
    type = "SystemAssigned"
  }

  addon_profile {
    http_application_routing {
      enabled = false
    }

    kube_dashboard {
      enabled = false
    }

    azure_policy {
      enabled = false
    }

    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = azurerm_log_analytics_workspace.aks_log_aw.id
    }

    aci_connector_linux {
      enabled     = true
      subnet_name = var.aci_subnet_name
    }
  }

  network_profile {
    network_plugin = "azure"
  }

  role_based_access_control {
    enabled = true
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      default_node_pool["node_count"],
      default_node_pool["max_count"],
      default_node_pool["min_count"],
    ]
  }

}


resource "azurerm_log_analytics_workspace" "aks_log_aw" {
  name                = "${var.pjname}workspace"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  retention_in_days   = var.aks_log_analytics_workspace_retention_in_days

  tags = var.tags
}

resource "azurerm_log_analytics_solution" "aks_log_as" {
  solution_name         = "ContainerInsights"
  location              = azurerm_resource_group.aks_rg.location
  resource_group_name   = azurerm_resource_group.aks_rg.name
  workspace_resource_id = azurerm_log_analytics_workspace.aks_log_aw.id
  workspace_name        = azurerm_log_analytics_workspace.aks_log_aw.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }

  tags = var.tags
}

data "azurerm_user_assigned_identity" "aks_aci_identity" {
  name                = "aciconnectorlinux-${azurerm_kubernetes_cluster.aks_cluster.name}"
  resource_group_name = "MC_${var.pjname}aks_${var.pjname}aks_${azurerm_resource_group.aks_rg.location}"
  depends_on = [azurerm_kubernetes_cluster.aks_cluster]
}

resource "azurerm_role_assignment" "aks_aci_subnet_assignment" {
  scope                = var.aci_subnet_id
  role_definition_name = "Network Contributor"
  principal_id         = data.azurerm_user_assigned_identity.aks_aci_identity.principal_id
}

data "azurerm_user_assigned_identity" "aks_agentpool_identity" {
  name                = "${var.pjname}aks-agentpool"
  resource_group_name = "MC_${var.pjname}aks_${var.pjname}aks_${azurerm_resource_group.aks_rg.location}"
  depends_on = [azurerm_kubernetes_cluster.aks_cluster]
}

resource "azurerm_role_assignment" "aks_acr_assignment" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = data.azurerm_user_assigned_identity.aks_agentpool_identity.principal_id
}