variable "resource_group_name" {
  description = "Name of the Azure Resource Group."
  default     = "money-saver-rg"
}

variable "location" {
  description = "Azure region for resources."
  default     = "westeurope"
}

variable "automation_account_name" {
  description = "Name of the Azure Automation Account."
  default     = "moneySaverAutomation"
}

variable "start_time_utc" {
  description = "Start time for the schedule in UTC (YYYY-MM-DDTHH:MM:SSZ)."
}


variable "automation_account_subscription_id" {
  description = "Azure Subscription ID."
  type        = string
}

variable "sandbox_subscriptions" {
  description = "List of Azure Subscription IDs for sandbox environments."
  type        = list(string)
  default     = []
}