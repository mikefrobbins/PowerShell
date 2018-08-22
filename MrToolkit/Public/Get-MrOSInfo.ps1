#Requires -Version 3.0
function Get-MrOSInfo {

<#
.SYNOPSIS
    Gets basic operating system properties.
 
.DESCRIPTION
    The Get-MrOSInfo function gets basic operating system properties for the local computer or for one or more remote
    computers.
 
 .PARAMETER CimSession
    Specifies the CIM session to use for this function. Enter a variable that contains the CIM session or a command that
    creates or gets the CIM session, such as the New-CimSession or Get-CimSession cmdlets. For more information, see
    about_CimSessions.

.EXAMPLE
    Get-MrOSInfo

.EXAMPLE
    Get-MrOSInfo -CimSession (New-CimSession -ComputerName Server01, Server02)

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
        [Microsoft.Management.Infrastructure.CimSession[]]$CimSession
    )

    $Params = @{}

    if ($PSBoundParameters.CimSession) {
        $Params.CimSession = $CimSession
    }
   
    $OSInfo = Get-CimInstance @Params -ClassName Win32_OperatingSystem -Property Caption, BuildNumber, OSArchitecture, CSName

    $OSVersion = Invoke-CimMethod @Params -Namespace root\cimv2 -ClassName StdRegProv -MethodName GetSTRINGvalue -Arguments @{
                    hDefKey=[uint32]2147483650; sSubKeyName='SOFTWARE\Microsoft\Windows NT\CurrentVersion'; sValueName='ReleaseId'}

    $PSVersion = Invoke-CimMethod @Params -Namespace root\cimv2 -ClassName StdRegProv -MethodName GetSTRINGvalue -Arguments @{
                    hDefKey=[uint32]2147483650; sSubKeyName='SOFTWARE\Microsoft\PowerShell\3\PowerShellEngine'; sValueName='PowerShellVersion'}

    foreach ($OS in $OSInfo) {
        if (-not $PSBoundParameters.CimSession) {
            $OSVersion.PSComputerName = $OS.CSName
            $PSVersion.PSComputerName = $OS.CSName
        }
        
        $PS = $PSVersion | Where-Object PSComputerName -eq $OS.CSName
                    
        if (-not $PS.sValue) {
            $Params2 = @{}
            
            if ($PSBoundParameters.CimSession) {
                $Params2.CimSession = $CimSession | Where-Object ComputerName -eq $OS.CSName
            }

            $PS = Invoke-CimMethod @Params2 -Namespace root\cimv2 -ClassName StdRegProv -MethodName GetSTRINGvalue -Arguments @{
                        hDefKey=[uint32]2147483650; sSubKeyName='SOFTWARE\Microsoft\PowerShell\1\PowerShellEngine'; sValueName='PowerShellVersion'}
        }
            
        [pscustomobject]@{
            ComputerName = $OS.CSName
            OperatingSystem = $OS.Caption
            Version = ($OSVersion | Where-Object PSComputerName -eq $OS.CSName).sValue
            BuildNumber = $OS.BuildNumber
            OSArchitecture = $OS.OSArchitecture
            PowerShellVersion = $PS.sValue
                                        
        }
            
    }

}
