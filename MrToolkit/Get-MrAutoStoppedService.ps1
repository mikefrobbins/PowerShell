function Get-MrAutoStoppedService {
    
<#
.SYNOPSIS
    Returns a list of services that are set to start automatically, are not
    currently running, excluding the services that are set to delayed start.
 
.DESCRIPTION
    Get-MrAutoStoppedService is a function that returns a list of services from
    the specified remote computer(s) that are set to start automatically, are not
    currently running, and it excludes the services that are set to start automatically
    with a delayed startup. This function is compatible to PowerShell version 2 and
    requires PowerShell remoting to be enabled on the remote computer.
 
.PARAMETER ComputerName
    The remote computer(s) to check the status of the services on.

.PARAMETER Credential
    Specifies a user account that has permission to perform this action. The default
    is the current user.
 
.EXAMPLE
     Get-MrAutoStoppedService -ComputerName 'Server1', 'Server2'

.EXAMPLE
     'Server1', 'Server2' | Get-MrAutoStoppedService

.EXAMPLE
     Get-MrAutoStoppedService -ComputerName 'Server1', 'Server2' -Credential (Get-Credential)
 
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
        $Params = @{
        }
 
        If ($PSBoundParameters['Credential']) {
            $Params.Credential = $Credential
        }
    }

    PROCESS {

        $Params.ComputerName = $ComputerName

        Invoke-Command @Params {

            $autoServices = Get-WmiObject -Class Win32_Service -Filter {State != 'Running' and StartMode = 'Auto' and Name != 'ShellHWDetection' and Name != 'SysmonLog'} |
                            Select-Object -ExpandProperty Name

            $delayedServices = Get-ChildItem -Path 'HKLM:\SYSTEM\CurrentControlSet\Services' |
                               Where-Object {$_.property -contains 'DelayedAutoStart'} |
                               Get-ItemProperty |
                               Where-Object {$_.Start -eq 2 -and $_.DelayedAutoStart -eq 1} |
                               Select-Object -ExpandProperty PSChildName

            Compare-Object -ReferenceObject $autoServices -DifferenceObject $delayedServices |
            Where-Object {$_.SideIndicator -eq '<='} | 
            Select-Object -Property @{label='ServiceName';expression={$_.InputObject}} |
            Get-Service

        }
    }
}