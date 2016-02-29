#Requires -Version 3.0
function Get-MrLeapYear2 {

<#
.SYNOPSIS
   Get-MrLeapYear is used to determine whether or not a specific year is a leap year.
.DESCRIPTION
   Get-MrLeapYear is a function that is used to determine whether or not the specified
   year(s) are leap years. Contrary to popular belief, leap year does not occur every
   four years: http://en.wikipedia.org/wiki/Leap_year
.PARAMETER Year
   The year(s) specified in integer form that you would like to determine whether or
   not they are a leap year.
.EXAMPLE
   Get-MrLeapYear
.EXAMPLE
   Get-MrLeapYear -Year 2010, 2011, 2012, 2013, 2014, 2015
.EXAMPLE
   1890..1910 | Get-MrLeapYear
.INPUTS
   Integer
.OUTPUTS
   String
.NOTES
   Author:  Mike F Robbins
   Website: http://mikefrobbins.com
   Twitter: @mikefrobbins
#>
    
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        [ValidateRange(1582,9999)]
        [int[]]$Year = (Get-Date).Year
    )

    PROCESS {
        foreach ($y in $Year) {
            try {
                if (Get-Date -Date 2/29/$y) {
                    Write-Output "$y is a leap year"
                }
            }
            catch {
                Write-Output "$y is not a leap year"
            }
        }
    }
}