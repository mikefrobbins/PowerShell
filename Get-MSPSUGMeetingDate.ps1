#Requires -Version 3.0
function Get-MSPSUGMeetingDate {
<#
.SYNOPSIS
    Returns the meeting dates for the Mississippi PowerShell User Group.
.DESCRIPTION
    Get-MSPSUGMeetingDate is a function that returns the dates when
    the Mississippi PowerShell User Group meetings are held.
.PARAMETER Month
    The month to return the meeting dates for. The default is all months.
.PARAMETER Year
    The year to return the meeting dates for. The default is the current year.
.EXAMPLE
    Get-MSPSUGMeetingDate
.EXAMPLE
    Get-MSPSUGMeetingDate -Year 2014, 2015
.EXAMPLE
    Get-MSPSUGMeetingDate -Year (2013..2020)
.EXAMPLE
    Get-MSPSUGMeetingDate -Month July, September
.EXAMPLE
    Get-MSPSUGMeetingDate -Month (7..10) -Year 2014, 2015
.EXAMPLE
    2014, 2015 | Get-MSPSUGMeetingDate
.EXAMPLE
    2013..2020 | Get-MSPSUGMeetingDate -Month July, September
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
        [ValidateNotNullOrEmpty()]
        [string[]]$Month = (1..12),

        [Parameter(ValueFromPipeline)]
        [ValidateRange(2013,9999)]
        [Int[]]$Year = (Get-Date).Year
    )
    PROCESS {
        foreach ($y in $Year) {
            foreach ($m in $Month) {
                [datetime]$meetingDate = "$m 1, $y"
                while ($meetingDate.DayOfWeek -ne 'Tuesday') {
                    $meetingDate = $meetingDate.AddDays(1)
                }
                [PSCustomObject]@{
                    'Year' = $y
                    'MeetingDate' = $($meetingDate.AddDays(7).AddHours(20).AddMinutes(30))
                }
            }
        }
    }
}