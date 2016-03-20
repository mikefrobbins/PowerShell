function Get-MrLeapYear {

<#
.SYNOPSIS
   Get-MrLeapYear is used to determine whether or not a specific year is a leap year.
.DESCRIPTION
   Get-LeapYear is a function that is used to determine whether or not the specified
   year(s) are leap years. Contrary to popular belief, leap year does not occur every
   four years. According to Wikipedia, if a year is divisible by 400 then it's a leap
   year, else if the year is divisible by 100 then it's a normal year, else if the year
   is divisible by 4 then it's a leap year, else it's a normal year. Source:
   http://en.wikipedia.org/wiki/Leap_year
.PARAMETER Year
   The year(s) specified in integer form that you would like to determine whether or
   not they are a leap year. The default is the current year.
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
        [Parameter(ValueFromPipeline=$true)]
        [ValidateRange(1582,9999)]
        [int[]]$Year = (Get-Date).Year
    )

    PROCESS {
        foreach ($y in $Year) {
            if ($y / 400 -is [int]) {
                Write-Output "$y is a leap year"
            }
            elseif ($y / 100 -is [int]) {
                Write-Output "$y is not a leap year"
            }
            elseif ($y / 4 -is [int]) {
                Write-Output "$y is a leap year"
            }
            else {
                Write-Output "$y is not a leap year"
            }
        }
    }
}