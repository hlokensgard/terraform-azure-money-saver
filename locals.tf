locals {
  runbook_name = "MoneySaver"
  automation_account_vars = {
    sandboxsubscriptions = join(",", var.sandbox_subscriptions)
  }
  schedules = {
    firewall = {
      name       = "dailyFirewallSchedule"
      parameters = { stopfirewalls = "true" }
      frequency  = "Day"
      interval   = 1
    }
    app_gateway = {
      name       = "dailyAppGatewaySchedule"
      parameters = { stopapplicationgateways = "true" }
      frequency  = "Day"
      interval   = 1
    }
    vm_vmss = {
      name       = "dailyVMVMSSchedule"
      parameters = { stopvmsandvmss = "true" }
      frequency  = "Day"
      interval   = 1
    }
    sandbox_cleanup = {
      name       = "byweeklySandboxCleanupSchedule"
      parameters = { stopsandboxcleanup = "true" }
      frequency  = "Week"
      interval   = 2
    }
  }
}
