function Get-MrFunctionsToExport {

<#
.SYNOPSIS
    Returns a list of functions in the specified directory.
 
.DESCRIPTION
    Get-MrFunctionsToExport is an advanced function which returns a list of functions
    that are each contained in single quotes and each separated by a comma unless the
    simple parameter is specified in which case a simple list of the base file names
    for the functions is returned.
 
.PARAMETER Path
    Path to the folder where the functions are located.

.PARAMETER Exclude
    Pattern to exclude. By default profile scripts and Pester tests are excluded.

.PARAMETER Recurse
    Return function names from subdirectories in addition to the specified directory.

.PARAMETER Simple
    Return a simple list instead of a quoted comma separated list.

.EXAMPLE
    Get-MrFunctionsToExport -Path .\MrToolkit

.EXAMPLE
    Get-MrFunctionsToExport -Path .\MrToolkit -Simple

.INPUTS
    None
 
.OUTPUTS
    String
 
.NOTES
    Author:  Mike F Robbins
    Website: http://mikefrobbins.com
    Twitter: @mikefrobbins
#>

    [CmdletBinding()]
    param (
        [ValidateScript({
          If (Test-Path -Path $_ -PathType Container) {
            $True
          }
          else {
            Throw "'$_' is not a valid directory."
          }
        })]
        [string]$Path = (Get-Location),

        [string[]]$Exclude = ('*profile.ps1', '*.tests.ps1'),

        [switch]$Recurse,

        [switch]$Simple
    )

    $Params = @{
        Exclude = $Exclude
    }

    if ($PSBoundParameters.Recurse) {
        $Params.Recurse = $true
    }

    $results = Get-ChildItem -Path "$Path\*.ps1" @Params |
               Select-Object -ExpandProperty BaseName    
    
    if ((-not($PSBoundParameters.Simple)) -and $results) {
        $results = $results -join "', '"
        Write-Output "'$results'"
    }        
    elseif ($results) {
        Write-Output $results
    }
    
}