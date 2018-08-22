#Requires -Version 3.0 -Modules Pester
function Test-MrFunctionsToExport {

<#
.SYNOPSIS
    Tests that all functions in a module are being exported.
 
.DESCRIPTION
    Test-MrFunctionsToExport is an advanced function that runs a Pester test against
    one or more modules to validate that all functions are being properly exported.
 
.PARAMETER ManifestPath
    Path to the module manifest (PSD1) file for the modules(s) to test.

.EXAMPLE
    Test-MrFunctionsToExport -ManifestPath .\MyModuleManifest.psd1

.EXAMPLE
    Get-ChildItem -Path .\Modules -Include *.psd1 -Recurse | Test-MrFunctionsToExport

.INPUTS
    String
 
.OUTPUTS
    None
 
.NOTES
    Author:  Mike F Robbins
    Website: http://mikefrobbins.com
    Twitter: @mikefrobbins
#>

    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        [ValidateScript({
            Test-ModuleManifest -Path $_
        })]
        [string[]]$ManifestPath
    )
    
    PROCESS {
        foreach ($Manifest in $ManifestPath) {

            $ModuleInfo = Import-Module -Name $Manifest -Force -PassThru

            $PS1FileNames = Get-ChildItem -Path "$($ModuleInfo.ModuleBase)\functions\*.ps1" -Exclude *tests.ps1, *profile.ps1 |
                            Select-Object -ExpandProperty BaseName

            $ExportedFunctions = Get-Command -Module $ModuleInfo.Name |
                                 Select-Object -ExpandProperty Name

            Describe "FunctionsToExport for PowerShell module '$($ModuleInfo.Name)'" {

                It 'Exports one function in the module manifest per PS1 file' {
                    $ModuleInfo.ExportedFunctions.Values.Name.Count |
                    Should Be $PS1FileNames.Count
                }

                It 'Exports functions with names that match the PS1 file base names' {
                    Compare-Object -ReferenceObject $ModuleInfo.ExportedFunctions.Values.Name -DifferenceObject $PS1FileNames |
                    Should BeNullOrEmpty
                }

                It 'Only exports functions listed in the module manifest' {
                    $ExportedFunctions.Count |
                    Should Be $ModuleInfo.ExportedFunctions.Values.Name.Count
                }

                It 'Contains the same function names as base file names' {
                    Compare-Object -ReferenceObject $PS1FileNames -DifferenceObject $ExportedFunctions |
                    Should BeNullOrEmpty
                }
        
            }
    
        }

    }

}