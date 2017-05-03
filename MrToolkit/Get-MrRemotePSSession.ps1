#Requires -Version 3.0
function Get-MrRemotePSSession {

<#
.SYNOPSIS
    Retrieves a list of the Windows PowerShell sessions that are connected to the specified remote computer(s).
 
.DESCRIPTION
    The Get-MrRemotePSSession function gets the user-managed Windows PowerShell sessions (PSSessions) on remote
    computers even if they were not created in the current session.
 
.PARAMETER ComputerName
    Specifies an array of names of computers. Gets the sessions that connect to the specified computers.
    Wildcard characters are not permitted. The default value is the local computer.

.PARAMETER Credential
    Specifies a user credential. This function runs the command with the permissions of the specified user.
    Specify a user account that has permission to connect to the remote computer. The default is the current
    user. Type a user name, such as `User01`, `Domain01\User01`, or `User@Domain.com`, or enter a PSCredential
    object, such as one returned by the Get-Credential cmdlet. When you type a user name, this cmdlet prompts
    you for a password.
 
.EXAMPLE
     Get-MrRemotePSSession -ComputerName Server01, Server02 -Credential (Get-Credential)

.EXAMPLE
     'Server01', 'Server02' | Get-MrRemotePSSession -Credential (Get-Credential)

.INPUTS
    String
 
.OUTPUTS
    PSCustomObject
 
.NOTES
    Author:  Mike F Robbins
    Website: http://mikefrobbins.com
    Twitter: @mikefrobbins
#>

    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        [string[]]$ComputerName = $env:COMPUTERNAME ,
        
        [System.Management.Automation.Credential()]$Credential = [System.Management.Automation.PSCredential]::Empty
    )

    BEGIN {
        $Params = @{
            ResourceURI = 'shell'
            Enumerate = $true
        }

        if ($PSBoundParameters.Credential) {
            $Params.Credential = $Credential
        }
    }

    PROCESS {
        foreach ($Computer in $ComputerName) {
            $Params.ConnectionURI = "http://$($Computer):5985/wsman"

            Get-WSManInstance @Params |
            Select-Object -Property @{label='PSComputerName';expression={$Computer}}, Name, Owner, ClientIP, State        
        }
    }

}