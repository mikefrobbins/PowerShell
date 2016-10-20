#Requires -Version 2.0
function Get-MrAvailableDriveLetter {

<#
.SYNOPSIS
    Returns one or more available drive letters.
 
.DESCRIPTION
    Get-MrAvailableDriveLetter is an advanced PowerShell function that returns one or more available
    drive letters depending on the specified parameters.
 
.PARAMETER ExcludeDriveLetter
    Drive letter(s) to exclude regardless if they're available or not. The default excludes drive letters
    A-F and Z.

.PARAMETER Random
    Return one or more available drive letters at random instead of the next available drive letter.

.PARAMETER All
    Return all available drive letters. The default is to only return the first available drive letter.
 
.EXAMPLE
     Get-MrAvailableDriveLetter

.EXAMPLE
     Get-MrAvailableDriveLetter -ExcludeDriveLetter A-C

.EXAMPLE
     Get-MrAvailableDriveLetter -Random

.EXAMPLE
     Get-MrAvailableDriveLetter -All

.EXAMPLE
     Get-MrAvailableDriveLetter -ExcludeDriveLetter A-C, M, Q, T, W-Z -All

.EXAMPLE
     Get-MrAvailableDriveLetter -Random -All

.EXAMPLE
     Get-MrAvailableDriveLetter -ExcludeDriveLetter $null -Random -All

.INPUTS
    None
 
.OUTPUTS
    String
 
.NOTES
    Author:  Mike F Robbins
    Website: http://mikefrobbins.com
    Twitter: @mikefrobbins
#>

    [CmdletBinding()]
    param (
        [string[]]$ExcludeDriveLetter = ('A-F', 'Z'),

        [switch]$Random,

        [switch]$All
    )
    
    $Drives = Get-ChildItem -Path Function:[a-z]: -Name

    if ($ExcludeDriveLetter) {
        $Drives = $Drives -notmatch "[$($ExcludeDriveLetter -join ',')]"
    }

    if ($Random) {
        $Drives = $Drives | Get-Random -Count $Drives.Count
    }

    if (-not($All)) {
        
        foreach ($Drive in $Drives) {
            if (-not(Test-Path -Path $Drive)){
                return $Drive
            }
        }

    }
    else {
        Write-Output $Drives | Where-Object {-not(Test-Path -Path $_)}
    }

}