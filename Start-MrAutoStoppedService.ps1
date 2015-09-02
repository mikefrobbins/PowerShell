#Requires -Version 3.0
function Start-MrAutoStoppedService {
    
<#
.SYNOPSIS
    Starts services that are set to start automatically, are not currently running,
    excluding the services that are set to delayed start.
 
.DESCRIPTION
    Start-MrAutoStoppedService is a function that starts services on the specified
    remote computer(s) that are set to start automatically, are not currently running,
    and it excludes the services that are set to start automatically with a delayed
    startup. This function is compatible to PowerShell version 2 and requires
    PowerShell remoting to be enabled on the remote computer.
 
.PARAMETER ComputerName
    The remote computer(s) to check the status and start the services on.

.PARAMETER Credential
    Specifies a user account that has permission to perform this action. The default
    is the current user.

.PARAMETER PassThru
    Returns an object representing the service. By default, this function  does not
    generate any output.
     
.EXAMPLE
     Start-MrAutoStoppedService -ComputerName 'Server1', 'Server2'

.EXAMPLE
     Start-MrAutoStoppedService -ComputerName 'Server1', 'Server2' -PassThru

.EXAMPLE
     'Server1', 'Server2' | Start-MrAutoStoppedService

.EXAMPLE
     Start-MrAutoStoppedService -ComputerName 'Server1', 'Server2' -Credential (Get-Credential)
      
.INPUTS
    String
 
.OUTPUTS
    None or ServiceController
 
.NOTES
    Author:  Mike F Robbins
    Website: http://mikefrobbins.com
    Twitter: @mikefrobbins
#>

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory,
                   ValueFromPipeline,
                   ValueFromPipelineByPropertyName)]
        [string[]]$ComputerName,

        [System.Management.Automation.Credential()]$Credential = [System.Management.Automation.PSCredential]::Empty,

        [switch]$PassThru
    )

    BEGIN {
        $Params = @{}
        $RemoteParams = @{}

        switch ($PSBoundParameters) {
            {$_.keys -contains 'Credential'} {$Params.Credential = $Credential}
            {$_.keys -contains 'PassThru'} {$RemoteParams.PassThru = $true}
            {$_.keys -contains 'Confirm'} {$RemoteParams.Confirm = $true}
            {$_.keys -contains 'WhatIf'} {$RemoteParams.WhatIf = $true}
        }

    }

    PROCESS {
        $Params.ComputerName = $ComputerName

        Invoke-Command @Params {            
            $Services = Get-WmiObject -Class Win32_Service -Filter {
                State != 'Running' and StartMode = 'Auto'
            }
            
            foreach ($Service in $Services.Name) {
                Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\$Service" |
                Where-Object {$_.Start -eq 2 -and $_.DelayedAutoStart -ne 1} |
                Select-Object -Property @{label='ServiceName';expression={$_.PSChildName}} |
                Start-Service @Using:RemoteParams
            }            
        }
    }
}