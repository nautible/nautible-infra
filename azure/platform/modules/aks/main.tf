resource "azurerm_resource_group" "aks_rg" {
  name     = "${var.pjname}aks"
  location = var.location
}

resource "azurerm_subnet" "subnet" {
  count                                          = length(var.subnet_names)
  name                                           = var.subnet_names[count.index]
  resource_group_name                            = var.vnet_rg_name
  virtual_network_name                           = var.vnet_name
  address_prefixes                               = [var.subnet_cidrs[count.index]]
  enforce_private_link_endpoint_network_policies = true

  dynamic "delegation" {
    for_each = var.subnet_names[count.index] == "aksacisubnet" ? ["true"] : []
    content {
      name = "aciDelegation"
      service_delegation {
        name    = "Microsoft.ContainerInstance/containerGroups"
        actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
      }
    }
  }

}

resource "azurerm_network_security_group" "aks_security_group" {
  name                = "${var.pjname}akssg"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name

  security_rule {
    name                       = "https"
    priority                   = 500
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "http"
    priority                   = 501
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = var.cluster_inbound_http_port_range
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "aks_aci_security_group" {
  name                = "${var.pjname}aksacisg"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
}

resource "azurerm_subnet_network_security_group_association" "aks_subnet_nsga" {
  subnet_id                 = azurerm_subnet.subnet[0].id
  network_security_group_id = azurerm_network_security_group.aks_security_group.id
}

resource "azurerm_subnet_network_security_group_association" "aks_aci_subnet_nsga" {
  subnet_id                 = azurerm_subnet.subnet[1].id
  network_security_group_id = azurerm_network_security_group.aks_aci_security_group.id
}

# don't use Azure/terraform-azurerm-aks , because
# can't set role_based_access_control = true && azure_active_directory = false

resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = "${var.pjname}aks"
  kubernetes_version  = var.kubernetes_version
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  dns_prefix          = var.pjname

  default_node_pool {
    orchestrator_version  = var.kubernetes_version
    name                  = "agentpool"
    vm_size               = var.node_vm_size
    os_disk_size_gb       = var.node_os_disk_size_gb
    vnet_subnet_id        = azurerm_subnet.subnet[0].id
    enable_auto_scaling   = true
    max_count             = var.node_max_count
    min_count             = var.node_min_count
    node_count            = var.node_count
    enable_node_public_ip = false
    node_labels           = { "nodepool" = "defaultnodepool" }
    tags                  = merge(var.tags, { "Agent" = "defaultnodepoolagent" })
    max_pods              = var.max_pods

  }

  identity {
    type = "SystemAssigned"
  }

  http_application_routing_enabled = false
  azure_policy_enabled             = false
  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.aks_log_aw.id
  }
  aci_connector_linux {
    subnet_name = azurerm_subnet.subnet[1].name
  }

  network_profile {
    network_plugin = "azure"
  }

  role_based_access_control_enabled = true

  api_server_authorized_ip_ranges = var.api_server_authorized_ip_ranges

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
  retention_in_days   = var.log_analytics_workspace_retention_in_days

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
  depends_on          = [azurerm_kubernetes_cluster.aks_cluster]
}

resource "azurerm_role_assignment" "aks_aci_subnet_assignment" {
  scope                = azurerm_subnet.subnet[1].id
  role_definition_name = "Network Contributor"
  principal_id         = data.azurerm_user_assigned_identity.aks_aci_identity.principal_id
}

data "azurerm_user_assigned_identity" "aks_agentpool_identity" {
  name                = "${var.pjname}aks-agentpool"
  resource_group_name = "MC_${var.pjname}aks_${var.pjname}aks_${azurerm_resource_group.aks_rg.location}"
  depends_on          = [azurerm_kubernetes_cluster.aks_cluster]
}

resource "azurerm_role_assignment" "aks_acr_assignment" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = data.azurerm_user_assigned_identity.aks_agentpool_identity.principal_id
}
