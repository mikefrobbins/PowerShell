#Requires -Version 3.0
function Add-MrStartupVariable {

<#
.SYNOPSIS
    Add variable for list of startup variables.
 
.DESCRIPTION
    Add variable for list of startup variables to the specified PowerShell profile. Create the specified PowerShell
    profile if it does not exist. Only adds the variable and code to populate the variable if it does not already exist.
    Designed to be used in conjunction with Remove-MrUserVariable.
 
.PARAMETER Location
    Location of the PowerShell profile to add the startup variable to.
 
.EXAMPLE
     Add-MrStartupVariable -Location AllUsersCurrentHost

.INPUTS
    None
 
.OUTPUTS
    None
 
.NOTES
    Author:  Mike F Robbins
    Website: http://mikefrobbins.com
    Twitter: @mikefrobbins
#>

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [ValidateSet('AllUsersAllHosts', 'AllUsersCurrentHost', 'CurrentUserAllHosts', 'CurrentUserCurrentHost')]
        $Location
    )

    $Content = @'
$StartupVars = @()
$StartupVars = Get-Variable | Select-Object -ExpandProperty Name
'@

    if (-not(Test-Path -Path $profile.$Location)) {
        New-Item -Path $profile.$Location -ItemType File |
        Set-Content -Value $Content
    }
    elseif (-not(Get-Content -Path $profile.$Location |
             Select-String -SimpleMatch '$StartupVars = Get-Variable | Select-Object -ExpandProperty Name')) {
        Add-Content -Path $profile.$Location -Value "`r`n$Content"
    }
    else {
        Write-Verbose -Message "`$StartupVars already exists in '$($profile.$Location)'"
    }

}