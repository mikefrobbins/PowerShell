#Requires -Version 3.0
function Get-MrPipelineInput {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Name,
        
        [System.Management.Automation.WhereOperatorSelectionMode]$Option = 'Default',
        
        [ValidateRange(1,2147483647)]
        [int]$Records = 2147483647
    )

    (Get-Command -Name $Name).ParameterSets.Parameters.Where({
        $_.ValueFromPipeline -or $_.ValueFromPipelineByPropertyName
    }, $Option, $Records).ForEach({
        [pscustomobject]@{
            ParameterName = $_.Name
            ParameterType = $_.ParameterType
            ValueFromPipeline = $_.ValueFromPipeline
            ValueFromPipelineByPropertyName = $_.ValueFromPipelineByPropertyName
        }
    })

}
