provider "azurerm" {
  features {} // required but empty ok
}
resource "azurerm_resource_group" "aks_planned_outage" {
  name     = "${var.pjname}aksplannedoutage"
  location = var.location
}

resource "azurerm_automation_account" "aks_planned_outage_account" {
  name                = "${var.pjname}aksplannedoutage"
  location            = azurerm_resource_group.aks_planned_outage.location
  resource_group_name = azurerm_resource_group.aks_planned_outage.name
  sku_name            = "Basic"
  identity {
    type = "SystemAssigned"
  }
  tags = {}
}

resource "azurerm_role_assignment" "automation_account_ra" {
  scope                = "/subscriptions/${data.azurerm_subscription.current.subscription_id}"
  role_definition_name = "Contributor"
  principal_id         = azurerm_automation_account.aks_planned_outage_account.identity[0].principal_id
}

data "local_file" "aks_start_stop_ps" {
  filename = "${path.module}/aks-start-stop.ps1"
}

resource "azurerm_automation_runbook" "aks_start_stop" {
  name                    = "aksstartstop"
  location                = azurerm_resource_group.aks_planned_outage.location
  resource_group_name     = azurerm_resource_group.aks_planned_outage.name
  automation_account_name = azurerm_automation_account.aks_planned_outage_account.name
  log_verbose             = "true"
  log_progress            = "true"
  description             = "aksstartstop"
  runbook_type            = "PowerShell"

  content = data.local_file.aks_start_stop_ps.content
}

resource "azurerm_automation_schedule" "aks_start_schedule" {
  name                    = "aksstartschedule"
  resource_group_name     = azurerm_resource_group.aks_planned_outage.name
  automation_account_name = azurerm_automation_account.aks_planned_outage_account.name
  frequency               = "Week"
  interval                = 1
  timezone                = "Asia/Tokyo"
  start_time              = var.aks_start_schedule_time
  week_days               = var.aks_start_stop_schedule_weekdays
}

resource "azurerm_automation_schedule" "aks_stop_schedule" {
  name                    = "aksstopschedule"
  resource_group_name     = azurerm_resource_group.aks_planned_outage.name
  automation_account_name = azurerm_automation_account.aks_planned_outage_account.name
  frequency               = "Week"
  interval                = 1
  timezone                = "Asia/Tokyo"
  start_time              = var.aks_stop_schedule_time
  week_days               = var.aks_start_stop_schedule_weekdays
}

data "azurerm_subscription" "current" {
}

resource "azurerm_automation_job_schedule" "start_job_schedule" {
  resource_group_name     = azurerm_resource_group.aks_planned_outage.name
  automation_account_name = azurerm_automation_account.aks_planned_outage_account.name
  schedule_name           = azurerm_automation_schedule.aks_start_schedule.name
  runbook_name            = azurerm_automation_runbook.aks_start_stop.name

  parameters = {
    subscriptionid = data.azurerm_subscription.current.subscription_id
    action         = "start"
  }
}

resource "azurerm_automation_job_schedule" "stop_job_schedule" {
  resource_group_name     = azurerm_resource_group.aks_planned_outage.name
  automation_account_name = azurerm_automation_account.aks_planned_outage_account.name
  schedule_name           = azurerm_automation_schedule.aks_stop_schedule.name
  runbook_name            = azurerm_automation_runbook.aks_start_stop.name

  parameters = {
    subscriptionid = data.azurerm_subscription.current.subscription_id
    action         = "stop"
  }
}
