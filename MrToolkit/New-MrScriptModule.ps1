function New-MrScriptModule {
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

    Out-File -FilePath (Join-Path -Path $Path -ChildPath "$Name.psm1") -Encoding utf8
    Add-Content -Path (Join-Path -Path $Path -ChildPath "$Name.psm1") -Value '#Dot source all functions in all ps1 files located in the module folder
Get-ChildItem -Path $PSScriptRoot\*.ps1 -Exclude *.tests.ps1, *profile.ps1 |
ForEach-Object {
    . $_.FullName
}'
    New-ModuleManifest -Path (Join-Path -Path $Path -ChildPath "$Name.psd1") -RootModule $Name -Author $Author -Description $Description -CompanyName $CompanyName `
    -PowerShellVersion $PowerShellVersion -AliasesToExport $null -FunctionsToExport $null -VariablesToExport $null -CmdletsToExport $null
}
