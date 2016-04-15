function Get-MrAutoService {
    
<#
.SYNOPSIS
    Returns a list of services that are set to start automatically, excluding the
    services that are set to delayed start.
 
.DESCRIPTION
    Get-MrAutoService is a function that returns a list of services from
    the specified remote computer(s) that are set to start automatically and it
    excludes the services that are set to start automatically with a delayed startup.
    This function is compatible to PowerShell version 2 and requires PowerShell
    remoting to be enabled on the remote computer.
 
.PARAMETER ComputerName
    The remote computer(s) to check the status of the services on.

.PARAMETER Credential
    Specifies a user account that has permission to perform this action. The default
    is the current user.
 
.EXAMPLE
     Get-MrAutoService -ComputerName 'Server1', 'Server2'

.EXAMPLE
     'Server1', 'Server2' | Get-MrAutoStoppedService

.EXAMPLE
     Get-MrAutoService -ComputerName 'Server1', 'Server2' -Credential (Get-Credential)
 
.INPUTS
    String
 
.OUTPUTS
    ServiceController
 
.NOTES
    Author:  Mike F Robbins
    Website: http://mikefrobbins.com
    Twitter: @mikefrobbins
#>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [string[]]$ComputerName,

        [System.Management.Automation.Credential()]$Credential = [System.Management.Automation.PSCredential]::Empty
    )

    BEGIN {        
        $Params = @{}
 
        If ($PSBoundParameters['Credential']) {
            $Params.Credential = $Credential
        }
    }

    PROCESS {
        $Params.ComputerName = $ComputerName

        Invoke-Command @Params {
            $Services = Get-WmiObject -Class Win32_Service -Filter {
                StartMode = 'Auto'
            } -Property Name | Select-Object -ExpandProperty Name
            
            foreach ($Service in $Services) {
                Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\$Service" |
                Where-Object {$_.Start -eq 2 -and $_.DelayedAutoStart -ne 1} |
                Select-Object -Property @{label='ServiceName';expression={$_.PSChildName}} |
                Get-Service
            }
        }
    }
}