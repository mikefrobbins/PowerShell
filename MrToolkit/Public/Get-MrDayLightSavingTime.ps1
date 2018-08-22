#Requires -Version 3.0
function Get-MrDayLightSavingTime {

<#
.SYNOPSIS
    Returns the beginning and ending date for daylight saving time.
.DESCRIPTION
    Get-MrDayLightSavingTime is a function that returns the dates when
    daylight saving time begins and ends for the specified year.
.PARAMETER Year
    The year to return the daylight saving time dates for. The year cannot
    be earlier than 2007 because the dates were in April and October instead
    of March and November prior to that year. The default is the current year.
.EXAMPLE
    Get-MrDayLightSavingTime
.EXAMPLE
    Get-MrDayLightSavingTime -Year 2014, 2015
.EXAMPLE
    Get-MrDayLightSavingTime -Year (2011..2020)
.EXAMPLE
    2014, 2015 | Get-MrDayLightSavingTime
.EXAMPLE
    2011..2020 | Get-MrDayLightSavingTime
.INPUTS
    Integer
.OUTPUTS
    PSCustomObject
.NOTES
    Written by Mike F Robbins
    Blog: http://mikefrobbins.com
    Twitter: @mikefrobbins
#>
    
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        [ValidateRange(2007,9999)]
        [Int[]]$Year = (Get-Date).Year
    )

    PROCESS {
        foreach ($y in $Year) {

            [datetime]$beginDate = "March 1, $y"
    
            while ($beginDate.DayOfWeek -ne 'Sunday') {
                $beginDate = $beginDate.AddDays(1)
            }

            [datetime]$endDate = "November 1, $y"
    
            while ($endDate.DayOfWeek -ne 'Sunday') {
                $endDate = $endDate.AddDays(1)
            }            
            
            [PSCustomObject]@{
                'Year' = $y
                'BeginDate' = $($beginDate.AddDays(7).AddHours(2))
                'EndDate' = $($endDate.AddHours(2))
            }

        }
    }
}