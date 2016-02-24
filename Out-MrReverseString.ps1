#Requires -Version 3.0
function Out-MrReverseString {

<#
.SYNOPSIS
    Reverse the characters for one or more strings.
 
.DESCRIPTION
    Out-MrReverseString is a PowerShell function that reverses or flips the content in
    one or more strings. 
 
.PARAMETER String
    The content to be reversed. Mandatory parameter that accepts a single string or an
    array of strings.
 
.EXAMPLE
     Out-MrReverseString -String mikefrobbins.com, mspsug.com
 
.EXAMPLE
     'mikefrobbins.com', 'mspsug.com' | Out-MrReverseString
 
.INPUTS
    String
 
.OUTPUTS
    String
 
.NOTES
    Author:  Mike F Robbins
    Website: http://mikefrobbins.com
    Twitter: @mikefrobbins
#>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory,
                   ValueFromPipeline)]
        [string[]]$String
    )

    PROCESS {
        foreach ($s in $String) {
            $Array = $s -split ''
            [System.Array]::Reverse($Array)
            Write-Output ($Array -join '')
        }
    }

}