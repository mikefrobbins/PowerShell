Describe 'FunctionsToExport' {
    Context 'Numbers' {

        $ModuleName = (Import-Module -Name .\*.psd1 -Force -PassThru).Name
        $PS1FileNames = Get-ChildItem -Path $PSScriptRoot\*.ps1 -Exclude *tests.ps1, *profile.ps1 | Select-Object -ExpandProperty BaseName
        $ExportedFunctions = Get-Command -Module $ModuleName | Select-Object -ExpandProperty Name

        It 'Exports one function per PS1 file' {
            $ExportedFunctions.Count | Should Be $PS1FileNames.Count
        }

        It 'Contains the same function names as base file names' {
            Compare-Object -ReferenceObject $PS1FileNames -DifferenceObject $ExportedFunctions |
            Should BeNullOrEmpty
        }
        
    }

}