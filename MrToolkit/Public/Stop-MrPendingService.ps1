function Stop-MrPendingService {

<#
.SYNOPSIS
    Stops one or more services that is in a state of 'stop pending'.
 
.DESCRIPTION
     Stop-MrPendingService is a function that is designed to stop any service
     that is hung in the 'stop pending' state. This is accomplished by forcibly
     stopping the hung services underlying process.

.PARAMETER ComputerName
    The remote computer(s) to stop the hung service on.

.PARAMETER Credential
    Specifies a user account that has permission to perform this action. The default
    is the current user.

.EXAMPLE
     Stop-MrPendingService -ComputerName Server01, Server02

.EXAMPLE
     'Server01', 'Server02' | Stop-MrPendingService -Credential (Get-Credential)

.INPUTS
    String
 
.OUTPUTS
    Process
 
.NOTES
    Author:  Mike F Robbins
    Website: http://mikefrobbins.com
    Twitter: @mikefrobbins
#>

    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        [ValidateNotNullorEmpty()]
        [string[]]$ComputerName = $env:COMPUTERNAME,

        [System.Management.Automation.Credential()]$Credential = [System.Management.Automation.PSCredential]::Empty
    )

    PROCESS {    
        [array]$Computer += $ComputerName    
    }

    END {
    
        $Params = @{
            ComputerName = $Computer
        }

        If ($PSBoundParameters.Credential) {
            $Params.Credential = $Credential
        }

        Invoke-Command @Params {
            Get-WmiObject -Class Win32_Service -Filter {state = 'Stop Pending'} |
            ForEach-Object {Stop-Process -Id $_.ProcessId -Force -PassThru}
        }
    
    }

}