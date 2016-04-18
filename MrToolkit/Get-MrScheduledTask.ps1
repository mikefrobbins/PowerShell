#Requires -Version 3.0
function Get-MrScheduledTask {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [string[]]$ComputerName,
        
        [string]$TaskName,

        [System.Management.Automation.Credential()]$Credential = [System.Management.Automation.PSCredential]::Empty
    )

    $Params = @{
        ComputerName = $ComputerName
    }

    if ($PSBoundParameters.Credential) {
        $Params.Credential = $Credential
    }

    Invoke-Command @Params {
        if ($Using:PSBoundParameters.TaskName) {
            schtasks.exe /Query /FO CSV /TN $Using:TaskName /V | ConvertFrom-Csv
        }
        else {
            schtasks.exe /Query /FO CSV /V | ConvertFrom-Csv
        }

    } -HideComputerName |
    Select-Object -Property @{label='ComputerName';expression={$_.hostname}},
                            @{label='Name';expression={$_.taskname -replace '^.*\\'}},
                            @{label='NextRunTime';expression={$_.'next run time'}},
                            Status,
                            @{label='LogonMode';expression={$_.'Logon Mode'}},
                            @{label='LastRunTime';expression={$_.'Last Run Time'}},
                            @{label='LastResult';expression={$_.'last result'}},
                            Author,
                            @{label='TaskToRun';expression={$_.'Task to Run'}},
                            Comment,
                            @{label='State';expression={$_.'Scheduled Task State'}},
                            @{label='RunAsUser';expression={$_.'Run as User'}},
                            @{label='ScheduleType';expression={$_.'Schedule Type'}},
                            @{label='StartTime';expression={$_.'start time'}},
                            @{label='StartDate';expression={$_.'Start Date'}},
                            Days

}
