output "automation_account_identity_principal_id" {
  description = "Principal ID of the system-assigned managed identity for the Automation Account."
  value       = azurerm_automation_account.main.identity[0].principal_id
}
output "resource_group" {
  description = "The entire resource group resource."
  value       = azurerm_resource_group.main
}

output "automation_account" {
  description = "The entire automation account resource."
  value       = azurerm_automation_account.main
}