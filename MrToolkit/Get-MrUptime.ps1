#Requires -Version 3.0
function Get-MrUptime {

<#
.SYNOPSIS
    Returns the uptime for the specified computer(s).
 
.DESCRIPTION
    Get-MrUptime is an advanced function that retrieves the uptime for one or more
    computers that are specified via a CIM session.
 
.PARAMETER CimSession
    The previously created CimSession using New-Cimsession or New-MrCimSession.

.EXAMPLE
     New-MrCimSession -ComputerName Server01, Server02 | Get-MrUptime

.EXAMPLE
     Get-MrUptime -CimSession (New-MrCimSession -ComputerName Server01, Server02)

.INPUTS
    Microsoft.Management.Infrastructure.CimSession
 
.OUTPUTS
    Selected.Microsoft.Management.Infrastructure.CimInstance
 
.NOTES
    Author:  Mike F Robbins
    Website: http://mikefrobbins.com
    Twitter: @mikefrobbins
#>

    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        [Microsoft.Management.Infrastructure.CimSession[]]$CimSession
    )

    PROCESS {
        [array]$CimSessions += $CimSession
    }
    
    END {
        Get-CimInstance -CimSession $CimSessions -ClassName Win32_OperatingSystem -Property LocalDateTime, LastBootUpTime |
        Select-Object -Property PSComputerName, @{label='Uptime';expression={$_.LocalDateTime - $_.LastBootUpTime}}

        $CimSessions | Remove-CimSession -ErrorAction SilentlyContinue
    }

}
