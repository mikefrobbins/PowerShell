#Requires -Version 3.0
function Get-MrInternetConnectionSharing {

<#
.SYNOPSIS
    Retrieves the status of Internet connection sharing for the specified network adapter(s).
 
.DESCRIPTION
    Get-MrInternetConnectionSharing is an advanced function that retrieves the status of Internet connection sharing
    for the specified network adapter(s).
 
.PARAMETER InternetInterfaceName
    The name of the network adapter(s) to check the Internet connection sharing status for.
 
.EXAMPLE
    Get-MrInternetConnectionSharing -InternetInterfaceName Ethernet, 'Internal Virtual Switch'

.EXAMPLE
    'Ethernet', 'Internal Virtual Switch' | Get-MrInternetConnectionSharing

.EXAMPLE
    Get-NetAdapter | Get-MrInternetConnectionSharing

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
                   ValueFromPipeline,
                   ValueFromPipelineByPropertyName)]
        [Alias('Name')]
        [string[]]$InternetInterfaceName
    )

    BEGIN {
        regsvr32.exe /s hnetcfg.dll
        $netShare = New-Object -ComObject HNetCfg.HNetShare
    }

    PROCESS {
        foreach ($Interface in $InternetInterfaceName){
        
            $publicConnection = $netShare.EnumEveryConnection |
            Where-Object {
                $netShare.NetConnectionProps.Invoke($_).Name -eq $Interface
            }
            
            try {
                $Results = $netShare.INetSharingConfigurationForINetConnection.Invoke($publicConnection)
            }
            catch {
                Write-Warning -Message "An unexpected error has occurred for network adapter: '$Interface'"
                Continue
            }

            [pscustomobject]@{
                Name = $Interface
                SharingEnabled = $Results.SharingEnabled
                SharingConnectionType = $Results.SharingConnectionType
                InternetFirewallEnabled = $Results.InternetFirewallEnabled
            }
            
        }
    
    }    

}