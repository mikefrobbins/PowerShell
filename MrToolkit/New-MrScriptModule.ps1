function New-MrScriptModule {

<#
.SYNOPSIS
    Creates a new PowerShell script module in the specified location.
 
.DESCRIPTION
    New-MrScriptModule is an advanced function that creates a new PowerShell script module in the
    specified location including creating the module folder and both the PSM1 script module file
    and PSD1 module manifest.
 
.PARAMETER Name
    Name of the script module.

.PARAMETER Path
    Parent path of the location to create the script module in. This location must already exist.

.PARAMETER Author
    Specifies the module author.

.PARAMETER CompanyName
    Identifies the company or vendor who created the module.

.PARAMETER Description
    Describes the contents of the module.

.PARAMETER PowerShellVersion
    Specifies the minimum version of Windows PowerShell that will work with this module. For example,
    you can enter 3.0, 4.0, or 5.0 as the value of this parameter.
 
.EXAMPLE
     New-MrScriptModule -Name MyModuleName -Path "$env:ProgramFiles\WindowsPowerShell\Modules" -Author 'Mike F Robbins' -CompanyName mikefrobbins.com -Description 'Brief description of my PowerShell module' -PowerShellVersion 3.0

.INPUTS
    None
 
.OUTPUTS
    None
 
.NOTES
    Author:  Mike F Robbins
    Website: http://mikefrobbins.com
    Twitter: @mikefrobbins
#>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Name,
        
        [ValidateScript({
          If (Test-Path -Path $_ -PathType Container) {
            $true
          }
          else {
            Throw "'$_' is not a valid directory."
          }
        })]
        [String]$Path,

        [Parameter(Mandatory)]
        [string]$Author,

        [Parameter(Mandatory)]
        [string]$CompanyName,

        [Parameter(Mandatory)]
        [string]$Description,

        [Parameter(Mandatory)]
        [string]$PowerShellVersion
    )

    New-Item -Path $Path -Name $Name -ItemType Directory | Out-Null
    Out-File -FilePath "$Path\$Name\$Name.psm1" -Encoding utf8
    Add-Content -Path "$Path\$Name\$Name.psm1" -Value '#Dot source all functions in all ps1 files located in the module folder
Get-ChildItem -Path $PSScriptRoot\*.ps1 -Exclude *.tests.ps1, *profile.ps1 |
ForEach-Object {
    . $_.FullName
}'
    New-ModuleManifest -Path "$Path\$Name\$Name.psd1" -RootModule $Name -Author $Author -Description $Description -CompanyName $CompanyName `
    -PowerShellVersion $PowerShellVersion -AliasesToExport $null -FunctionsToExport $null -VariablesToExport $null -CmdletsToExport $null
}
