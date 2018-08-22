#Requires -Version 4.0
function Get-MrAST {

<#
.SYNOPSIS
    Explores the Abstract Syntax Tree (AST).
 
.DESCRIPTION
    Get-MrAST is an advanced function that provides a mechanism for exploring the Abstract Syntax Tree (AST).
 
.PARAMETER Code
    The code to view the AST for.

.PARAMETER Path
    Specifies a path to one or more locations. Wildcards are permitted. The default location is the current directory.
 
.EXAMPLE
     Get-MrAST -Path 'C:\Scripts' -AstType FunctionDefinition

.EXAMPLE
     Get-MrAST -Code "function Get-PowerShellProcess {Get-Process -Name PowerShell}" -AstType FunctionDefinition
 
.NOTES
    Author:  Mike F Robbins
    Website: http://mikefrobbins.com
    Twitter: @mikefrobbins
#>

    [CmdletBinding(DefaultParameterSetName='File')]
    param(
        [Parameter(ValueFromPipelineByPropertyName,
                   ValueFromRemainingArguments,
                   ParameterSetName = 'File',
                   Position = 0)]
        [ValidateNotNullOrEmpty()]
        [Alias('FilePath')]
        [string[]]$Path = ('.\*.ps1', '.\*.psm1'),

        [Parameter(Mandatory,
                   ValueFromPipeline,
                   ValueFromRemainingArguments,
                   ParameterSetName = 'Code',
                   Position = 0)]
        [Alias('ScriptBlock')]
        [string[]]$Code
    )
 
    DynamicParam {
            $ParameterName = 'AstType'
            $RuntimeParameterDictionary = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameterDictionary
            $AttributeCollection = New-Object -TypeName System.Collections.ObjectModel.Collection[System.Attribute]
            $ParameterAttribute = New-Object -TypeName System.Management.Automation.ParameterAttribute
            $ParameterAttribute.Position = 0
            $AttributeCollection.Add($ParameterAttribute) 
            $ValidationValues = Get-MrAstType -Simple
            $ValidateSetAttribute = New-Object -TypeName System.Management.Automation.ValidateSetAttribute($ValidationValues)
            $AttributeCollection.Add($ValidateSetAttribute)
            $RuntimeParameter = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string], $AttributeCollection)
            $RuntimeParameterDictionary.Add($ParameterName, $RuntimeParameter)
            $RuntimeParameterDictionary
    }

    BEGIN {        
        $AstType = $PsBoundParameters[$ParameterName]
        $Errors = $null
        $Tokens = $null
    }

    PROCESS {
        if ($PsBoundParameters.Code) {
            $AST = [System.Management.Automation.Language.Parser]::ParseInput($Code, [ref]$Tokens, [ref]$Errors)
        }
        elseif ($PsBoundParameters.Path) {
            $Files = Get-ChildItem -Path $Path | Select-Object -ExpandProperty FullName
            $AST = foreach ($File in $Files) {
                [System.Management.Automation.Language.Parser]::ParseFile($File, [ref]$Tokens, [ref]$Errors)
            }
        }
        
        if ($AstType) {
            Write-Output $AST.FindAll({$args[0].GetType().Name -like "*$ASTType*Ast"}, $true)
        }
        else {
            Write-Output $AST
        }
    }
}