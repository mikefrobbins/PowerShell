#Dot source all functions in all ps1 files located in the module folder
Get-ChildItem -Path $PSScriptRoot\*.ps1 -Exclude *tests.ps1, *profile.ps1 |
ForEach-Object {
    . $_.FullName
}