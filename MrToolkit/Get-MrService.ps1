#Requires -Version 3.0
function Get-MrService {

<#
.SYNOPSIS
    Gets the services on a local or remote computer.
 
.DESCRIPTION
    The Get-MrService function gets objects that represent the services on a local computer or on a remote computer,
    including running and stopped services. You can direct this function to get only particular services by specifying
    the service name of the services.
 
.PARAMETER Name
    Specifies the service names of services to be retrieved. Wildcards are permitted. By default, this function gets
    all of the services on the computer.
 
 .PARAMETER CimSession
    Specifies the CIM session to use for this cmdlet. Enter a variable that contains the CIM session or a command that
    creates or gets the CIM session, such as the New-CimSession or Get-CimSession cmdlets. For more information, see
    about_CimSessions.

.EXAMPLE
    Get-MrService -Name bits, w32time

.EXAMPLE
    Get-MrService -CimSession (New-CimSession -ComputerName Server01, Server02) -Name Win*

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
        [string[]]$Name = '*',

        [Microsoft.Management.Infrastructure.CimSession[]]$CimSession
    )

    $Params = @{}

    if ($PSBoundParameters.CimSession) {
        $Params.CimSession = $CimSession
    }    

    foreach ($n in $Name) {
        if ($n -match '\*') {
            $n = $n -replace '\*', '%'
        }
        
        $Services = Get-CimInstance -ClassName Win32_Service -Filter "Name like '$n'" @Params
        
        foreach ($Service in $Services) {
            $Params.CimSession = $CimSession | Where-Object ComputerName -eq $Service.SystemName

            if ($Service.ProcessId -ne 0) {
                $Process = Get-CimInstance -ClassName Win32_Process -Filter "ProcessId = '$($Service.ProcessId)'"
            }
            else {
                $Process = ''
            }
    
            [pscustomobject]@{
                ComputerName = $Service.SystemName
                Status = $Service.State
                Name = $Service.Name
                DisplayName = $Service.DisplayName
                StartTime = $Process.CreationDate
            }
        }

    }
    
}