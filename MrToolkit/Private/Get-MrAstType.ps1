#Requires -Version 4.0
function Get-MrAstType {
    param (
        [switch]$Simple
    )
    
    $Results = [System.Management.Automation.Language.ArrayExpressionAst].Assembly.GetTypes().Where({
        $_.Name.EndsWith('Ast') -and $_.Name -ne 'Ast'
    }).ForEach({
         "'{0}'" -f ($_.Name -replace '(?<!^)ExpressionAst$|Ast$')
    }) |
    Sort-Object -Unique
    
    if (-not($PSBoundParameters.Simple) -and $Results) {
        Write-Output ($Results -join ',')
    }
    elseif ($Results) {
        Write-Output $Results.Trim("'")
    }
    else {
        Write-Verbose -Message 'There were no results.'
    }

}
