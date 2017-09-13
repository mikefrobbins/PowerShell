#Requires -Version 2.0
function Get-MrNetFirewallState {

<#
.SYNOPSIS
    Displays the per-profile state of the Windows Firewall.
 
.DESCRIPTION
    The Get-MrNetFirewallState function displays the current firewall state for the Domain, Private, and Public profiles.
 
.PARAMETER ComputerName
    The name of the computer(s) to retrieve the firewall state for.

.PARAMETER Credential
    Specifies a user account that has permission to perform this action. The default is the current user.
 
.EXAMPLE
     Get-MrNetFirewallState

.EXAMPLE
     Get-MrNetFirewallState -ComputerName Server01, Server02

.EXAMPLE
     Get-MrNetFirewallState -ComputerName Server01, Server02 -Credential (Get-Credential)
 
.INPUTS
    None
 
.OUTPUTS
    PSCustomObject
 
.NOTES
    Author:  Mike F Robbins
    Website: http://mikefrobbins.com
    Twitter: @mikefrobbins
#>

    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [string[]]$ComputerName = $env:COMPUTERNAME,
        
        [System.Management.Automation.Credential()]$Credential = [System.Management.Automation.PSCredential]::Empty
    )
    
    $ScriptBlock =
@'
    $Results = netsh.exe advfirewall show allprofiles | Select-String -SimpleMatch Profile, State
    
    for ($i = 0; $i -lt 6; $i += 2) {
        New-Object PSObject -Property @{
            ComputerName = $env:COMPUTERNAME
            Name = ($Results[$i] | Select-String -SimpleMatch 'Profile Settings') -replace '^*.Profile Settings:'
            Enabled = if (($Results[$i+1] | Select-String -SimpleMatch 'State') -replace '^.*State\W*' -eq 'ON') {
                            $true
                        }
                        else {
                            $false
                        }
        }
    }
'@
    
    $Params = @{        
        Scriptblock = [Scriptblock]::Create($ScriptBlock)
    }
    
    if ($ComputerName -ne $env:COMPUTERNAME) {
        
        $Params.ComputerName = $ComputerName
        $Params.ErrorAction = 'SilentlyContinue'
        $Params.ErrorVariable = 'Problem'
        
        if ($PSBoundParameters.Credential) {
            $Params.Credential = $Credential
        }
            
        Invoke-Command @Params | Select-Object -Property ComputerName, Name, Enabled
        
        foreach ($p in $Problem) {
            if ($p.FullyQualifiedErrorId -match 'AccessDenied|LogonFailure') {
                Write-Warning -Message "Access Denied when trying to connect to $($p.TargetObject)" 
            }
            elseif ($p.FullyQualifiedErrorId -match 'NetworkPathNotFound') {
                Write-Warning -Message "Unable to connect to $($p.targetobject)"
            }
            else {
                Write-Warning -Message "An unexpected error has occurred when trying to connect to $($p.targetobject)"
            }
        }
        
    }
    else {
        $Params.ScriptBlock.Invoke()
    }

}