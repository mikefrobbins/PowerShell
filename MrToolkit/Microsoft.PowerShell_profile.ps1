$ProgressPreference = 'SilentlyContinue'

if (Test-NetConnection -ComputerName bing.com -Port 80 -InformationLevel Quiet -ErrorAction SilentlyContinue 3>$null) {

    $Now = Get-Date
    $Date = Get-Date -Month $Now.Month -Day 1
    $Book = (Invoke-WebRequest -Uri https://www.packtpub.com/packt/offers/free-learning/).ParsedHtml.getElementsByTagName('H2')[0].InnerHTML.Trim()

    while ($Date.DayOfWeek -ne 'Tuesday') {$Date = $Date.AddDays(1)}
    if ($Date.ToShortDateString() -eq $Now.ToShortDateString()) {
        Update-Module -Force
        Update-Help -ErrorAction SilentlyContinue
    }

    Write-Host 'The Packt Publishing free learning eBook of the day is: ' -ForegroundColor Cyan -NoNewline
    Write-Host "'$Book'" -ForegroundColor Yellow

}

$ProgressPreference = 'Continue'
