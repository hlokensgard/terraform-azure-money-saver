provider "azurerm" {
  features {
  }
  subscription_id = var.automation_account_subscription_id
}

module "money_saver" {
  source                             = "hlokensgard/money-saver/azure"
  version                            = "1.1.2"
  resource_group_name                = var.resource_group_name
  location                           = var.location
  automation_account_name            = var.automation_account_name
  start_time_utc                     = var.start_time_utc
  automation_account_subscription_id = var.automation_account_subscription_id
  sandbox_subscriptions              = var.sandbox_subscriptions
}