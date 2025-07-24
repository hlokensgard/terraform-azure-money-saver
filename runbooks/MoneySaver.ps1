param (
    [Parameter()]
    [bool]$stopfirewalls = $false,
    [Parameter()]
    [bool]$stopapplicationgateways = $false,
    [Parameter()]
    [bool]$stopvmsandvmss = $false,
    [Parameter()]
    [bool]$sandboxcleanup = $false
)

function Use-RequiredAzModules {
    Write-Output "Importing required Azure modules..."
    try {
        Import-Module Az.Resources -ErrorAction Stop
        Import-Module Az.Network -ErrorAction Stop
        Write-Output "Modules imported successfully."
    }
    catch {
        Write-Output -ForegroundColor Red "Error importing Azure modules: $_"
    }
}

function Connect-AzAutomation {
    Disable-AzContextAutosave –Scope Process
    while(!($connectionResult) -and ($logonAttempt -le 10))
    {
        $LogonAttempt++
        # Logging in to Azure...

        $connectionResult = Connect-AzAccount -Identity
        Start-Sleep -Seconds 30
    }
}

function Stop-Firewalls {
    param (
        [Parameter(Mandatory)]
        [string]$TenantId
    )
    $startTime = Get-Date
    Write-Output "Starting firewall stop process at: $startTime"

    try {
        Get-AzSubscription -TenantId $TenantId |
        ForEach-Object {
            Write-Output "Switching context to subscription: $($_.Name) ($($_.Id))"
            try {
                Select-AzSubscription -SubscriptionId $_.Id 
                $firewalls = Get-AzFirewall |
                Where-Object {-not ($_.Tags.Keys | Where-Object{ $_ -eq "keep"})} 
                if ($firewalls) {
                    Write-Output "Found $($firewalls.Count) firewall(s) in subscription $($_.Name)."
                    $firewalls | ForEach-Object {
                        $fw = $_
                        Write-Output "Processing firewall: $($fw.Name) in resource group: $($fw.ResourceGroupName)"
                        try {
                            Write-Output "Stopping firewall: $($fw.Name)..."
                            $fw.Deallocate()
                            $fw | Set-AzFirewall
                            Write-Output "Firewall $($fw.Name) stopped successfully."
                        }
                        catch {
                            Write-Output -ForegroundColor Red "Failed to stop firewall: $($fw.Name). Error: $_"
                        }
                    }
                }
                else {
                    Write-Output "No firewalls found in subscription $($_.Name)."
                }
            }
            catch {
                Write-Output -ForegroundColor Red "Error processing subscription $($_.Name): $_"
            }
        }
    }
    catch {
        Write-Output -ForegroundColor Red "Error during firewall stop operation: $_"
    }

    $duration = (Get-Date) - $startTime
    Write-Output ("Firewall stop operation completed. Total time: {0:hh}h {0:mm}min {0:ss}sec" -f $duration)
}

function Set-ApplicationGateways {
    param (
        [Parameter(Mandatory)]
        [string]$TenantId,
        [Parameter(Mandatory)]
        [ValidateSet("on", "off")]
        [string]$Operation
    )

    Write-Output "Starting Application Gateway management with operation: '$Operation'"
    try {
        Get-AzSubscription -TenantId $TenantId |
        ForEach-Object {
            $sub = $_
            Write-Output "Switching context to subscription: $($sub.Name) ($($sub.Id))"
            try {
                Select-AzSubscription -SubscriptionId $sub.Id | Out-Null

                Get-AzApplicationGateway |
                Where-Object {-not ($_.Tags.Keys | Where-Object{ $_ -eq "keep"})} |
                ForEach-Object {
                    $gateway = $_
                    $name = $gateway.Name
                    $state = $gateway.OperationalState
                    $rg = $gateway.ResourceGroupName
                    Write-Output "Processing gateway: $name in resource group: $rg"
                    Write-Output " - Current state: $state"

                    try {
                        if (($state -eq "Running") -and ($Operation -eq "off")) {
                            Write-Output " - Action: Stopping gateway $name..."
                            Stop-AzApplicationGateway -ApplicationGateway $gateway -ErrorAction Stop | Out-Null
                            Write-Output " - Gateway $name stopped."
                        }
                        elseif (($state -ne "Running") -and ($Operation -eq "on")) {
                            Write-Output " - Action: Starting gateway $name..."
                            $gateway | Start-AzApplicationGateway -ErrorAction Stop | Out-Null
                            Write-Output " - Gateway $name started."
                        }
                        else {
                            Write-Output " - Action: No change required for gateway $name."
                        }
                    }
                    catch {
                        Write-Output -ForegroundColor Red "Error managing gateway $($name): $_"
                    }
                }
            }
            catch {
                Write-Output -ForegroundColor Red "Error processing subscription $($sub.Name): $_"
            }
        }
    }
    catch {
        Write-Output -ForegroundColor Red "Error during Application Gateway management: $_"
    }
    Write-Output "Application Gateway management completed."
}

function Stop-NonTaggedVMsAndVMSS {
    param (
        [Parameter(Mandatory)]
        [string]$TenantId
    )

    Write-Output "Stopping all VMs and VMSS without 'keep' tag in all subscriptions for tenant: $TenantId"
    try {
        Get-AzSubscription -TenantId $TenantId | ForEach-Object {
            Write-Output "Switching context to subscription: $($_.Name) ($($_.Id))"
            try {
                Select-AzSubscription -SubscriptionId $_.Id | Out-Null

                $vms = Get-AzVM | Where-Object { -not ($_.Tags.Keys -contains "keep") }
                if ($vms) {
                    Write-Output "Found $($vms.Count) VM(s) without 'keep' tag."
                    try {
                        $vms | ForEach-Object {
                            Write-Output "Stopping VM: $($_.Name) in resource group: $($_.ResourceGroupName)"
                            $_ | Stop-AzVM -Force
                        }
                        Write-Output "All non-tagged VMs stopped."
                    }
                    catch {
                        Write-Output -ForegroundColor Red "Error stopping VMs: $_"
                    }
                }
                else {
                    Write-Output "No non-tagged VMs found."
                }

                $vmss = Get-AzVMss | Where-Object { -not ($_.Tags.Keys -contains "keep") }
                if ($vmss) {
                    Write-Output "Found $($vmss.Count) VMSS(s) without 'keep' tag."
                    try {
                        $vmss | ForEach-Object {
                            Write-Output "Stopping VMSS: $($_.Name) in resource group: $($_.ResourceGroupName)"
                            $_ | Stop-AzVmss -Force
                        }
                        Write-Output "All non-tagged VMSS stopped."
                    }
                    catch {
                        Write-Output -ForegroundColor Red "Error stopping VMSS: $_"
                    }
                }
                else {
                    Write-Output "No non-tagged VMSS found."
                }
            }
            catch {
                Write-Output -ForegroundColor Red "Error processing subscription $($_.Name): $_"
            }
        }
    }
    catch {
        Write-Output -ForegroundColor Red "Error during VM and VMSS stop operation: $_"
    }
    Write-Output "VM and VMSS stop operation completed."
}

function Remove-NonTaggedResourcesFromSandboxSubscriptions {
    param (
        [Parameter(Mandatory)]
        [array]$SandboxSubscriptions
    )

    Write-Output "Removing non-tagged resources from sandbox subscriptions..."
    foreach ($sub in $SandboxSubscriptions) {
        Write-Output "Switching context to sandbox subscription: $sub"
        try {
            Select-AzSubscription -SubscriptionId $sub | Out-Null

            $resourceGroups = Get-AzResourceGroup
            if ($resourceGroups) {
                Write-Output "Found $($resourceGroups.Count) resource group(s) in subscription $sub."
                $resourceGroups | ForEach-Object {
                    $rgName = $_.ResourceGroupName
                    Write-Output "Processing resource group: $rgName"
                    try {
                        $resources = Get-AzResource -ResourceGroupName $rgName | Where-Object { -not ($_.Tags.Keys -contains "keep") }
                        if ($resources) {
                            Write-Output "Found $($resources.Count) non-tagged resource(s) in resource group $rgName."
                            $resources | ForEach-Object {
                                try {
                                    Write-Output "Removing resource: $($_.Name) ($($_.ResourceType))"
                                    Remove-AzResource -ResourceId $_.ResourceId -Force
                                    Write-Output "Resource $($_.Name) removed."
                                }
                                catch {
                                    Write-Output -ForegroundColor Red "Error removing resource $($_.Name): $_"
                                }
                            }
                        }
                        else {
                            Write-Output "No non-tagged resources found in resource group $rgName."
                        }
                    }
                    catch {
                        Write-Output -ForegroundColor Red "Error processing resource group $($rgName): $_"
                    }
                }
            }
            else {
                Write-Output "No resource groups found in subscription $($sub)."
            }
        }
        catch {
            Write-Output -ForegroundColor Red "Error processing sandbox subscription $($sub): $_"
        }
    }
    Write-Output "Non-tagged resource removal from sandbox subscriptions completed."
}

function Invoke-MoneySaver {
    param (
        [Parameter()]
        [bool]$RunFirewalls = $false,
        [Parameter()]
        [bool]$RunApplicationGateways = $false,
        [Parameter()]
        [bool]$RunVMsAndVMSS = $false,
        [Parameter()]
        [bool]$RunSandboxCleanup = $false,
        [Parameter()]
        [array]$SandboxSubscriptions = @()
    )
    Use-RequiredAzModules
    Connect-AzAutomation
    #Connect-AzAutomation -SubscriptionId (Get-AutomationVariable -Name 'SubscriptionID')

    Write-Output "Retrieving current Azure Tenant ID..."
    try {
        $tenantId = Get-AzContext | Select-Object -ExpandProperty Tenant | Select-Object -ExpandProperty Id
        if (-not $tenantId) {
            Write-Output -ForegroundColor Red "Tenant ID could not be retrieved. Ensure you are authenticated to Azure."
        }
        else {
            Write-Output "Tenant ID retrieved: $tenantId"
        }
    }
    catch {
        Write-Output -ForegroundColor Red "Error retrieving Tenant ID: $_"
    }

    if ($RunFirewalls) {
        Write-Output "Invoking Stop-Firewalls..."
        Stop-Firewalls -TenantId $tenantId
    }
    if ($RunApplicationGateways) {
        Write-Output "Invoking Set-ApplicationGateways..."
        Set-ApplicationGateways -TenantId $tenantId -Operation "off"
    }
    if ($RunVMsAndVMSS) {
        Write-Output "Invoking Stop-NonTaggedVMsAndVMSS..."
        Stop-NonTaggedVMsAndVMSS -TenantId $tenantId
    }
    if ($RunSandboxCleanup) {
        Write-Output "Invoking Remove-NonTaggedResourcesFromSandboxSubscriptions..."
        Remove-NonTaggedResourcesFromSandboxSubscriptions -SandboxSubscriptions $sandboxSubscriptions
    }
}

$sandboxSubscriptions = (Get-AutomationVariable -Name 'sandboxsubscriptions' -ErrorAction SilentlyContinue)
$sandboxSubscriptions = $sandboxSubscriptions -split ","

Invoke-MoneySaver -RunFirewalls $stopfirewalls -RunApplicationGateways $stopapplicationgateways -RunVMsAndVMSS $stopvmsandvmss -RunSandboxCleanup $sandboxcleanup -SandboxSubscriptions $sandboxSubscriptions