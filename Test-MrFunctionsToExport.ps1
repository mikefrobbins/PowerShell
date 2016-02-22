#Requires -Version 3.0
#Add 'Requires -Modules Pester' if used without the script module
function Test-MrFunctionsToExport {
    [CmdletBinding()]
    param (
        [ValidateScript({
            Test-ModuleManifest -Path $_
        })]
        [string]$ManifestPath
    )
    
    $ModuleInfo = Import-Module -Name $ManifestPath -Force -PassThru

    $PS1FileNames = Get-ChildItem -Path "$($ModuleInfo.ModuleBase)\*.ps1" -Exclude *tests.ps1, *profile.ps1 |
                    Select-Object -ExpandProperty BaseName

    $ExportedFunctions = Get-Command -Module $ModuleInfo.RootModule |
                         Select-Object -ExpandProperty Name

    Describe 'FunctionsToExport' {

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