#Requires -Version 3.0
function Get-MrADLockOutInfo {

<# 
.SYNOPSIS 
    Get-MrADLockOutInfo returns a list of users who were locked out in Active Directory. 
  
.DESCRIPTION 
    Get-MrADLockOutInfo is an advanced function that returns a list of users who were locked out in Active Directory 
    by querying the event logs on the PDC emulation in the domain. 
  
.PARAMETER UserName 
    The userid of the specific user you are looking for lockouts for. The default is all locked out users. 
  
.PARAMETER StartTime 
    The datetime to start searching from. The default is all datetimes that exist in the event logs.

.PARAMETER Credential
    Specifies a user account that has permission to read the security event log on the PDC emulator in the forest root
    domain. The default is the current user.
  
.EXAMPLE 
    Get-MrADLockOutInfo 
  
.EXAMPLE 
    Get-MrADLockOutInfo -UserName 'mikefrobbins' 
  
.EXAMPLE 
    Get-MrADLockOutInfo -StartTime (Get-Date).AddDays(-1) 
  
.EXAMPLE 
    Get-MrADLockOutInfo -UserName 'mikefrobbins' -StartTime (Get-Date).AddDays(-1) 
#> 
 
    [CmdletBinding()] 
    param ( 
        [ValidateNotNullOrEmpty()] 
        [string]$DomainName = $env:USERDOMAIN, 
 
        [ValidateNotNullOrEmpty()] 
        [string]$UserName = '*', 
 
        [ValidateNotNullOrEmpty()] 
        [datetime]$StartTime = (Get-Date).AddDays(-3),

        [System.Management.Automation.Credential()]$Credential = [System.Management.Automation.PSCredential]::Empty
    )

    BEGIN {
        try {
            $ErrorActionPreference = 'Stop'

            $PdcEmulator = [System.DirectoryServices.ActiveDirectory.Domain]::GetDomain(( 
                New-Object System.DirectoryServices.ActiveDirectory.DirectoryContext('Domain', $DomainName)) 
            ).PdcRoleOwner.name

            Write-Verbose -Message "The PDC emulator in your forest root domain is: $PdcEmulator"
            $ErrorActionPreference = 'Continue'
        }
        catch {
            Write-Error -Message 'Unable to query the domain. Verify the user running this script has read access to Active Directory and try again.'
        }    
    }
    
    PROCESS {
        Invoke-Command -ComputerName $PdcEmulator { 
 
            Get-WinEvent -FilterHashtable @{LogName='Security';Id=4740;StartTime=$Using:StartTime} |
            Where-Object {$_.Properties[0].Value -like "$Using:UserName"} |
            Select-Object -Property TimeCreated,
                                    @{Label='UserName';Expression={$_.Properties[0].Value}},
                                    @{Label='ClientName';Expression={$_.Properties[1].Value}}
        } -Credential $Credential | 
        Select-Object -Property TimeCreated, UserName, ClientName
    }
}