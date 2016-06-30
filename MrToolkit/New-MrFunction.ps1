#Requires -Modules Pester
function New-MrFunction {
    [CmdletBinding()]
    param (
        [string]$Name,
        [string]$Path
    )

    New-Fixture -Path $Path -Name $Name
    Set-Content -Path (Join-Path -Path $Path -ChildPath "$Name.ps1") -Force -Value "function $($Name) {

<#
.SYNOPSIS
    Brief synopsis about the function.
 
.DESCRIPTION
    Detailed explanation of the purpose of this function.
 
.PARAMETER Param1
    The purpose of param1.

.PARAMETER Param2
    The purpose of param2.
 
.EXAMPLE
     $($Name) -Param1 'Value1', 'Value2'

.EXAMPLE
     'Value1', 'Value2' | $($Name)

.EXAMPLE
     $($Name) -Param1 'Value1', 'Value2' -Param2 'Value'
 
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
                   ValueFromPipeline)]
        [string[]]`$Param1,

        [ValidateNotNullOrEmpty()]
        [string]`$Param2
    )

    BEGIN {

    }

    PROCESS {

    }

    END {

    }

}"

}