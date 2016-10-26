#Requires -Version 2.0
function Test-MrIpAddress {

<#
.SYNOPSIS
    Tests one or more IP Addresses to determine if they are valid.
 
.DESCRIPTION
    Test-MrIpAddress is an advanced function that tests one or more IP Addresses to determine if
    they are valid. The detailed parameter can be used to return additional information about the IP.
 
.PARAMETER IpAddress
    One or more IP Addresses to test. This parameter is mandatory.

.PARAMETER Detailed
    Switch parameter to return detailed infomation about the IP Address instead of a boolean.
 
.EXAMPLE
     Test-MrIpAddress -IpAddress '192.168.0.1', '192.168.0.256'

.EXAMPLE
     Test-MrIpAddress -IpAddress '192.168.0.1' -Detailed

.EXAMPLE
     '::1', '192.168.0.256' | Test-MrIpAddress

.INPUTS
    String
 
.OUTPUTS
    Boolean
 
.NOTES
    Author:  Mike F Robbins
    Website: http://mikefrobbins.com
    Twitter: @mikefrobbins
#>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,
                   ValueFromPipeLine=$true)]
        [string[]]$IpAddress,

        [switch]$Detailed
    )

    PROCESS {

        foreach ($Ip in $IpAddress) {
    
            try {
                $Results = $Ip -match ($DetailedInfo = [IPAddress]$Ip)
            }
            catch {
                Write-Output $false
                Continue
            }

            if (-not($PSBoundParameters.Detailed)){
                Write-Output $Results
            }
            else {
                Write-Output $DetailedInfo
            }    
    
        }

    }

}