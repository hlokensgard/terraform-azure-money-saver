# terraform-azure-money-saver

This Terraform module helps you save costs in Azure test environments by automatically managing resource usage. It deploys an Azure Automation Account with preconfigured runbooks and schedules to stop or deallocate resources (such as VMs) at specified times, reducing unnecessary spend.

## Features

- Creates an Azure Automation Account and Resource Group.
- Deploys runbooks for cost-saving automation.
- Schedules runbooks to run daily at your chosen time.
- Supports multiple sandbox subscriptions.

## Usage

```hcl
module "money_saver" {
    source  = "github.com/hlokensgard/terraform-azure-money-saver"
    
    automation_account_subscription_id = "<your-subscription-id>"
    start_time_utc                    = "2024-06-01T22:00:00Z"
    sandbox_subscriptions             = ["<sandbox-sub-id-1>", "<sandbox-sub-id-2>"]

    # Optional overrides
    automation_account_name           = "customAutomationAccount"
    location                         = "westeurope"
    resource_group_name               = "custom-rg"
}
```

## Manual Steps Required

After deployment, you **must grant the system-assigned managed identity of the Automation Account** Contributor or similar permissions on each subscription where you want resources to be managed. This allows the runbooks to make changes (e.g., stop VMs) in those subscriptions.

## Example Workflow

1. Deploy the module with your desired settings.
2. Grant the Automation Account's managed identity Contributor permissions on target subscriptions.
3. The runbooks will execute daily, managing resources to minimize costs.

## License

MIT

## Further Possibilities

- Extend runbook functionality to support additional scenarios.
- Add remediation steps for policy compliance, such as targeted deletion of unused resources.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~>1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~>4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~>4.0 |

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