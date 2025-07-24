resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_automation_account" "main" {
  name                = var.automation_account_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku_name            = "Basic"
  identity {
    type = "SystemAssigned"
  }
  public_network_access_enabled = true
}

resource "azurerm_automation_runbook" "runbooks" {
  name                    = "MoneySaver"
  location                = azurerm_resource_group.main.location
  resource_group_name     = azurerm_resource_group.main.name
  automation_account_name = azurerm_automation_account.main.name
  runbook_type            = "PowerShell"
  log_verbose             = true
  log_progress            = true
  publish_content_link {
    uri = "https://raw.githubusercontent.com/hlokensgard/terraform-azure-money-saver/refs/heads/main/runbooks/${local.runbook_name}.ps1"
  }
}


resource "azurerm_automation_schedule" "daily" {
  for_each                = local.schedules
  name                    = each.value.name
  resource_group_name     = azurerm_resource_group.main.name
  automation_account_name = azurerm_automation_account.main.name
  frequency               = "Day"
  interval                = 1
  start_time              = var.start_time_utc == null ? timeadd(timestamp(), "1h") : var.start_time_utc
  timezone                = "UTC"
}

resource "azurerm_automation_job_schedule" "runbook_schedule_links" {
  for_each                = local.schedules
  resource_group_name     = azurerm_resource_group.main.name
  automation_account_name = azurerm_automation_account.main.name
  runbook_name            = azurerm_automation_runbook.runbooks.name
  schedule_name           = azurerm_automation_schedule.daily[each.key].name
  parameters              = each.value.parameters
}

resource "azurerm_automation_variable_string" "variables" {
  for_each                = local.automation_account_vars
  name                    = each.key
  resource_group_name     = azurerm_resource_group.main.name
  automation_account_name = azurerm_automation_account.main.name
  value                   = each.value
}
