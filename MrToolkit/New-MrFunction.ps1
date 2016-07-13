#Requires -Version 3.0 -Modules Pester
function New-MrFunction {

<#
.SYNOPSIS
    Creates a new PowerShell function in the specified location.
 
.DESCRIPTION
    New-MrFunction is an advanced function that creates a new PowerShell function in the
    specified location including creating a Pester test for the new function.
 
.PARAMETER Name
    Name of the function.

.PARAMETER Path
    Path of the location where to create the function. This location must already exist.
 
.EXAMPLE
     New-MrFunction -Name Get-MrPSVersion -Path "$env:ProgramFiles\WindowsPowerShell\Modules\MyModule"

.INPUTS
    None
 
.OUTPUTS
    System.IO.FileInfo
 
.NOTES
    Author:  Mike F Robbins
    Website: http://mikefrobbins.com
    Twitter: @mikefrobbins
#>

    [CmdletBinding()]
    [OutputType('System.IO.FileInfo')]
    param (
        [ValidateScript({
          If ((Get-Verb -Verb ($_ -replace '-.*$')).Verb) {
            $true
          }
          else {
            Throw "'$_' does NOT use an approved Verb."
          }
        })]
        [string]$Name,

        [ValidateScript({
          If (Test-Path -Path $_ -PathType Container) {
            $true
          }
          else {
            Throw "'$_' is not a valid directory."
          }
        })]
        [string]$Path
    )

    $FunctionPath = Join-Path -Path $Path -ChildPath "$Name.ps1"

    if (-not(Test-Path -Path $FunctionPath)) {
    
        New-Fixture -Path $Path -Name $Name
        Set-Content -Path $FunctionPath -Force -Value "#Requires -Version 3.0
function $($Name) {

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
    [OutputType('PSCustomObject')]
    param (
        [Parameter(Mandatory, 
                   ValueFromPipeline)]
        [string[]]`$Param1,

        [ValidateNotNullOrEmpty()]
        [string]`$Param2
    )

    BEGIN {
        #Used for prep. This code runs one time prior to processing items specified via pipeline input.
    }

    PROCESS {
        #This code runs one time for each item specified via pipeline input.

        foreach (`$Param in `$Param1) {
            #Use foreach scripting construct to make parameter input work the same as pipeline input (iterate through the specified items one at a time).
        }
    }

    END {
        #Used for cleanup. This code runs one time after all of the items specified via pipeline input are processed.
    }

}"
    
    }
    else {
        Write-Error -Message 'Unable to create function. Specified file already exists!'
    }    

}