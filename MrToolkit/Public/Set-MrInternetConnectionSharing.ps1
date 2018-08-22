#Requires -Version 3.0 -Modules NetAdapter
function Set-MrInternetConnectionSharing {

<#
.SYNOPSIS
    Configures Internet connection sharing for the specified network adapter(s).
 
.DESCRIPTION
    Set-MrInternetConnectionSharing is an advanced function that configures Internet connection sharing
    for the specified network adapter(s). The specified network adapter(s) must exist and must be enabled.
    To enable Internet connection sharing, Internet connection sharing cannot already be enabled on any
    network adapters.
 
.PARAMETER InternetInterfaceName
    The name of the network adapter to enable or disable Internet connection sharing for.
 
 .PARAMETER LocalInterfaceName
    The name of the network adapter to share the Internet connection with.

 .PARAMETER Enabled
    Boolean value to specify whether to enable or disable Internet connection sharing.

.EXAMPLE
    Set-MrInternetConnectionSharing -InternetInterfaceName Ethernet -LocalInterfaceName 'Internal Virtual Switch' -Enabled $true

.EXAMPLE
    'Ethernet' | Set-MrInternetConnectionSharing -LocalInterfaceName 'Internal Virtual Switch' -Enabled $false

.EXAMPLE
    Get-NetAdapter -Name Ethernet | Set-MrInternetConnectionSharing -LocalInterfaceName 'Internal Virtual Switch' -Enabled $true

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
        [ValidateScript({
            If ((Get-NetAdapter -Name $_ -ErrorAction SilentlyContinue -OutVariable INetNIC) -and (($INetNIC).Status -ne 'Disabled' -or ($INetNIC).Status -ne 'Not Present')) {
                $True
            }
            else {
                Throw "$_ is either not a valid network adapter of it's currently disabled."
            }
        })]
        [Alias('Name')]
        [string]$InternetInterfaceName,

        [ValidateScript({
            If ((Get-NetAdapter -Name $_ -ErrorAction SilentlyContinue -OutVariable LocalNIC) -and (($LocalNIC).Status -ne 'Disabled' -or ($INetNIC).Status -ne 'Not Present')) {
                $True
            }
            else {
                Throw "$_ is either not a valid network adapter of it's currently disabled."
            }
        })]
        [string]$LocalInterfaceName,

        [Parameter(Mandatory)]
        [bool]$Enabled
    )

    BEGIN {
        if ((Get-NetAdapter | Get-MrInternetConnectionSharing).SharingEnabled -contains $true -and $Enabled) {
            Write-Warning -Message 'Unable to continue due to Internet connection sharing already being enabled for one or more network adapters.'
            Break
        }

        regsvr32.exe /s hnetcfg.dll
        $netShare = New-Object -ComObject HNetCfg.HNetShare
    }
    
    PROCESS {
        
        $publicConnection = $netShare.EnumEveryConnection |
        Where-Object {
            $netShare.NetConnectionProps.Invoke($_).Name -eq $InternetInterfaceName
        }

        $publicConfig = $netShare.INetSharingConfigurationForINetConnection.Invoke($publicConnection)

        if ($PSBoundParameters.LocalInterfaceName) {
            $privateConnection = $netShare.EnumEveryConnection |
            Where-Object {
                $netShare.NetConnectionProps.Invoke($_).Name -eq $LocalInterfaceName
            }

            $privateConfig = $netShare.INetSharingConfigurationForINetConnection.Invoke($privateConnection)
        } 
        
        if ($Enabled) {
            $publicConfig.EnableSharing(0)
            if ($PSBoundParameters.LocalInterfaceName) {
                $privateConfig.EnableSharing(1)
            }
        }
        else {
            $publicConfig.DisableSharing()
            if ($PSBoundParameters.LocalInterfaceName) {
                $privateConfig.DisableSharing()
            }
        }

    }

}