#Requires -Version 3.0
function Get-MrEqlSANUptime {

<#
.SYNOPSIS
    Gets the uptime for one or more EqualLogic storage area network members.
 
.DESCRIPTION
    Get-MrEqlSANUptime is a PowerShell function that retrieves the firmware
    version, last boot time, and number of days of uptime from one or more
    EqualLogic storage area network members. This function depends on the
    EqlPSTools PowerShell module that is installed as part of the EqualLogic
    HIT Kit. 
 
.PARAMETER GroupAddress
    One or more IP Addresses of the EqualLogic storage area network(s) to
    return the uptime information for.
 
.PARAMETER ModulePath
    Full path to the EqlPSTools.dll file that is installed as part of the
    EqualLogic HIT Kit. This parameter defaults to the default location of
    this DLL file.

.PARAMETER Credential
    Specifies a user account that has permission to perform this action. The
    default is the current user.
 
.EXAMPLE
     Get-MrEqlSANUptime -GroupAddress 192.168.1.1 -Credential (Get-Credential)
 
.EXAMPLE
     Get-MrEqlSANUptime -GroupAddress 192.168.1.1 -ModulePath 'C:\Program Files\EqualLogic\bin\EqlPSTools.dll'
 
.EXAMPLE
     '192.168.1.1', '192.168.2.1' | Get-MrEqlSANUptime -Credential (Get-Credential)
 
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
        [Parameter(Mandatory,
                   ValueFromPipeline)]
        [string[]]$GroupAddress,
        
        [ValidateNotNullOrEmpty()]
        [string]$ModulePath = 'C:\Program Files\EqualLogic\bin\EqlPSTools.dll',
        
        [System.Management.Automation.Credential()]$Credential = [System.Management.Automation.PSCredential]::Empty
    )

    BEGIN {
        $problem = $false

        $Params = @{
            ErrorAction = 'Stop'
        }

        Write-Verbose -Message "Attempting to load EqlPSTools Module if it's not already loaded"
        if (-not (Get-Module -Name EqlPSTools)) {          
            try {
                Import-Module $ModulePath @Params
            }
            catch {
                $problem = $true
                Write-Warning -Message "An error has occured.  Error details: $_.Exception.Message"
            }
        }
 
        If ($PSBoundParameters['Credential']) {
            $Params.credential = $Credential
        }
    }

    PROCESS {
        if (-not ($problem)) {
            foreach ($Group in $GroupAddress) {
                $Params.GroupAddress = $Group

                try {
                    $Connect = Connect-EqlGroup @Params
                    Write-Verbose -Message "$Connect"
                }
                catch {
                    $Problem = $True
                    Write-Warning -Message "Please contact your system administrator. Reference error: $_.Exception.Message"
                }

                if (-not($Problem)) {
                    Get-EqlMember -GroupAddress $Group |
                    Select-Object -Property MemberName,
                                            @{label='FirmwareVersion';expression={$_.FirmwareVersion -replace '^.*V'}},
                                            @{label='BootTime';expression={(Get-Date).AddSeconds(-$_.Uptime)}},
                                            @{label='UpTime(Days)';expression={'{0:N2}' -f ($_.UpTime / 86400) }}

                    $Disconnect = Disconnect-EqlGroup -GroupAddress $Group
                    Write-Verbose -Message "$Disconnect"
                }

                $Problem = $false
            }
        }
    }
}