#Requires -Version 3.0
function Find-MrParameterAlias {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$CmdletName,

        [ValidateNotNullOrEmpty()]
        [string]$ParameterName = '*'
    )
        
    (Get-Command -Name $CmdletName).parameters.values |
    Where-Object Name -like $ParameterName |
    Select-Object -Property Name, Aliases
}
