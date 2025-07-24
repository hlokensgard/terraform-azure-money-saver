locals {
  runbook_name = "MoneySaver"
  automation_account_vars = {
    sandboxsubscriptions = join(",", var.sandbox_subscriptions)
  }
  schedules = {
    firewall = {
      name       = "dailyFirewallSchedule"
      parameters = { stopfirewalls = "true" }
    }
    app_gateway = {
      name       = "dailyAppGatewaySchedule"
      parameters = { stopapplicationgateways = "true" }
    }
    vm_vmss = {
      name       = "dailyVMVMSSchedule"
      parameters = { stopvmsandvmss = "true" }
    }
    sandbox_cleanup = {
      name       = "dailySandboxCleanupSchedule"
      parameters = { stopsandboxcleanup = "true" }
    }
  }
}
