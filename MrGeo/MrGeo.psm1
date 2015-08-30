#Requires -Version 3.0
function Get-MrGeoInformation {

<#
.SYNOPSIS
    Queries www.telize.com for Geolocation information based on IP Address.
 
.DESCRIPTION
    Get-MrGeoInformation is a PowerShell function that is designed to query
    www.telize.com for Geolocation information for one or more IPv4 or IPv6 IP
    Addresses. If an IP Address is not specified, your public IP Address is used.
 
.PARAMETER IPAddress
    The IPAddress(es) to return the Geolocation information for.
 
.EXAMPLE
     Get-MrGeoInformation
 
.EXAMPLE
     Get-MrGeoInformation -IPAddress '46.19.37.108', '2a02:2770::21a:4aff:feb3:2ee'
 
.EXAMPLE
     '46.19.37.108', '2a02:2770::21a:4aff:feb3:2ee' | Get-MrGeoInformation
 
.INPUTS
    IPAddress
 
.OUTPUTS
    GeoInfo
 
.NOTES
    Author:  Mike F Robbins
    Website: http://mikefrobbins.com
    Twitter: @mikefrobbins
#>

    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        [ipaddress[]]$IPAddress
    )

    PROCESS { 

        if (-not($PSBoundParameters.IPAddress)) {
            Write-Verbose -Message 'Attempting to retrieve Geolocation information for your public IP Address'
            $Results = Invoke-RestMethod -Uri 'http://www.telize.com/geoip' -TimeoutSec 30
        }
        else {
            $Results = foreach ($IP in $IPAddress) {
                Write-Verbose -Message "Attempting to retrieving Geolocation information for IP Address: '$IP'"
                Invoke-RestMethod -Uri "http://www.telize.com/geoip/$IP" -TimeoutSec 30
            }
        }

        foreach ($Result in $Results) {
            $Result.PSTypeNames.Insert(0,'Mr.GeoInfo')
            Write-Output $Result
        }       

    }

}