provider "azurerm" {
  features {} // required but empty ok
}
resource "azurerm_resource_group" "rm_servicebus" {
  name     = "${var.pjname}removeservicebus"
  location = var.location
}

resource "azurerm_automation_account" "rm_servicebus_account" {
  name                = "${var.pjname}removeservicebus"
  location            = azurerm_resource_group.rm_servicebus.location
  resource_group_name = azurerm_resource_group.rm_servicebus.name
  sku_name            = "Basic"
  identity {
    type = "SystemAssigned"
  }
  tags = {}
}

resource "azurerm_role_assignment" "automation_account_ra" {
  scope                = "/subscriptions/${data.azurerm_subscription.current.subscription_id}"
  role_definition_name = "Contributor"
  principal_id         = azurerm_automation_account.rm_servicebus_account.identity[0].principal_id
}

data "local_file" "rm_servicebus_ps" {
  filename = "${path.module}/rm-servicebus.ps1"
}

resource "azurerm_automation_runbook" "rm_servicebus" {
  name                    = "remove_servicebus"
  location                = azurerm_resource_group.rm_servicebus.location
  resource_group_name     = azurerm_resource_group.rm_servicebus.name
  automation_account_name = azurerm_automation_account.rm_servicebus_account.name
  log_verbose             = "true"
  log_progress            = "true"
  description             = "remove servicebus"
  runbook_type            = "PowerShell"

  content = data.local_file.rm_servicebus_ps.content
}

resource "azurerm_automation_schedule" "rm_servicebus_schedule" {
  name                    = "removeservicebusschedule"
  resource_group_name     = azurerm_resource_group.rm_servicebus.name
  automation_account_name = azurerm_automation_account.rm_servicebus_account.name
  frequency               = "Week"
  interval                = 1
  timezone                = "Asia/Tokyo"
  start_time              = var.schedule_time
  week_days               = var.schedule_weekdays
}

data "azurerm_subscription" "current" {
}

resource "azurerm_automation_job_schedule" "rm_servicebus_job_schedule" {
  resource_group_name     = azurerm_resource_group.rm_servicebus.name
  automation_account_name = azurerm_automation_account.rm_servicebus_account.name
  schedule_name           = azurerm_automation_schedule.rm_servicebus_schedule.name
  runbook_name            = azurerm_automation_runbook.rm_servicebus.name

  parameters = {
    subscriptionid = data.azurerm_subscription.current.subscription_id
  }
}
