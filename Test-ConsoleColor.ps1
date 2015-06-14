#Requires -Version 3.0 -Modules Pscx
function Test-ConsoleColor {

<#
.SYNOPSIS
    Tests all the different color combinations for the PowerShell console.
 
.DESCRIPTION
    Test-ConsoleColor is a PowerShell function that by default iterates through
    all of the possible color combinations for the PowerShell console. The PowerShell
    Community Extensions Module is required by the function. 
 
.PARAMETER Color
    One or more colors that is part of the System.ConsoleColor enumeration. Run
    [Enum]::GetValues([System.ConsoleColor]) in PowerShell to see the possible values.
 
.PARAMETER Paragraphs
    The number of latin paragraphs to generate during each foreground color test.
 
.PARAMETER Milliseconds
    Specifies how long to wait between each iteration of color changes in milliseconds.
 
.EXAMPLE
     Test-ConsoleColor
 
.EXAMPLE
     Test-ConsoleColor -Color Red, Blue, Green
 
.EXAMPLE
     Test-ConsoleColor -Paragraphs 7

.EXAMPLE
     Test-ConsoleColor -Milliseconds 300

.EXAMPLE
     Test-ConsoleColor -Color Red, Green, Blue -Paragraphs 7 -Milliseconds 300
 
.INPUTS
    String
 
.OUTPUTS
    None
 
.NOTES
    Author:  Mike F Robbins
    Website: http://mikefrobbins.com
    Twitter: @mikefrobbins
#>

    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [System.ConsoleColor[]]$Color = [System.Enum]::GetValues([System.ConsoleColor]),
        
        [ValidateNotNullOrEmpty()]
        [int]$Paragraphs = 5,
        
        [ValidateNotNullOrEmpty()]
        [int]$Milliseconds = 100
    )

    if ($Host.Name -ne 'ConsoleHost') {
        Throw 'This function can only be run in the PowerShell Console.'
    }
        
    $BG = [System.Console]::BackgroundColor
    $FG = [System.Console]::ForegroundColor
    $Title = [System.Console]::Title

    foreach ($BGColor in $Color) {        
        [System.Console]::BackgroundColor = $BGColor
        Clear-Host
        
        foreach ($FGColor in $Color) {
            [System.Console]::ForegroundColor = $FGColor
            [System.Console]::Title = "ForegroundColor: $FGColor / BackgroundColor: $BGColor"
            Clear-Host

            Write-Verbose -Message "Foreground Color is: $FGColor"
            Write-Verbose -Message "Background Color is $BGColor"

            Get-LoremIpsum -Length $Paragraphs
            Start-Sleep -Milliseconds $Milliseconds
        }
    }

    [System.Console]::BackgroundColor = $BG
    [System.Console]::ForegroundColor = $FG
    [System.Console]::Title = $Title
    Clear-Host

}
