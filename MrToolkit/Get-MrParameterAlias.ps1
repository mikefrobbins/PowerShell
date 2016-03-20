#Requires -Version 3.0
function Get-MrParameterAlias {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Name
    )

    (Get-Command -Name $Name).Parameters.Values |
    Where-Object Aliases |
    Select-Object -Property Name, Aliases

}