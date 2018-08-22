#Requires -Version 3.0
function Get-MrGeoInformation {

<#
.SYNOPSIS
    Queries ip-api.com for Geolocation information based on IP Address.
 
.DESCRIPTION
    Get-MrGeoInformation is a PowerShell function that is designed to query
    ip-api.com (free for non-commercial use) for Geolocation information for one
    or more IPv4 or IPv6 IP Addresses. If an IP Address is not specified, your
    public IP Address is used.
 
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
            $Results = Invoke-RestMethod -Uri 'http://ip-api.com/json/' -TimeoutSec 30
        }
        else {
            $Results = foreach ($IP in $IPAddress) {
                Write-Verbose -Message "Attempting to retrieving Geolocation information for IP Address: '$IP'"
                Invoke-RestMethod -Uri "http://ip-api.com/json/$IP" -TimeoutSec 30
            }
        }

        foreach ($Result in $Results) {
            [pscustomobject]@{
                AutonomousSystem = $Result.as
                City = $Result.city
                Country = $Result.country
                CountryCode = $Result.countryCode
                ISP = $Result.isp
                Latitude = $Result.lat
                Longitude = $Result.lon
                Organization = $Result.org
                IPAddress = $Result.query
                Region = $Result.region
                RegionName = $Result.regionName
                Status = $Result.status
                TimeZone = $Result.timezone
                ZipCode = $Result.zip
                PSTypeName = 'Mr.GeoInfo'
            }

        }       

    }

}