function Get-MrParameterAlias {

    [CmdletBinding()]
    param (
        [string]$Name
    )

    (Get-Command -Name $Name).Parameters.Values |
    Where-Object Aliases |
    Select-Object -Property Name, Aliases

}