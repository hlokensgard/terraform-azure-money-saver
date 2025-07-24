# terraform-azure-money-saver
This module deploys an Automation Account with preconfigured runbooks to help minimize costs in your test environments by automatically managing resource usage.

## Manual Action Required

Grant the system-assigned managed identity of the Automation Account Contributor or similar permissions on each subscription where you want changes to be made.

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_automation_account.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_account) | resource |
| [azurerm_automation_job_schedule.runbook_schedule_links](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_job_schedule) | resource |
| [azurerm_automation_runbook.runbooks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_runbook) | resource |
| [azurerm_automation_schedule.daily](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_schedule) | resource |
| [azurerm_automation_variable_string.variables](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_variable_string) | resource |
| [azurerm_resource_group.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_role_assignment.automation_account_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_automation_account_subscription_id"></a> [automation\_account\_subscription\_id](#input\_automation\_account\_subscription\_id) | Azure Subscription ID. | `string` | n/a | yes |
| <a name="input_start_time_utc"></a> [start\_time\_utc](#input\_start\_time\_utc) | Start time for the schedule in UTC (YYYY-MM-DDTHH:MM:SSZ). | `any` | n/a | yes |
| <a name="input_automation_account_name"></a> [automation\_account\_name](#input\_automation\_account\_name) | Name of the Azure Automation Account. | `string` | `"moneySaverAutomation"` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region for resources. | `string` | `"westeurope"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the Azure Resource Group. | `string` | `"money-saver-rg"` | no |
| <a name="input_sandbox_subscriptions"></a> [sandbox\_subscriptions](#input\_sandbox\_subscriptions) | List of Azure Subscription IDs for sandbox environments. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_automation_account"></a> [automation\_account](#output\_automation\_account) | The entire automation account resource. |
| <a name="output_automation_account_identity_principal_id"></a> [automation\_account\_identity\_principal\_id](#output\_automation\_account\_identity\_principal\_id) | Principal ID of the system-assigned managed identity for the Automation Account. |
| <a name="output_resource_group"></a> [resource\_group](#output\_resource\_group) | The entire resource group resource. |
<!-- END_TF_DOCS -->