$Global:ProgressPreference = 'SilentlyContinue'

if (Test-NetConnection -ComputerName bing.com -Port 80 -InformationLevel Quiet -ErrorAction SilentlyContinue -WarningAction SilentlyContinue) {

    $Now = Get-Date
    $Date = Get-Date -Month $Now.Month -Day 1
    
    while ($Date.DayOfWeek -ne 'Tuesday') {$Date = $Date.AddDays(1)}
        
    if ($Date.ToShortDateString() -eq $Now.ToShortDateString()) {

        $PSLUPath = "$env:ProgramFiles\WindowsPowerShell\Configuration\pshelp-lastupdated.txt"

        $PSHelpLastUpdate = (Get-ChildItem -Path $PSLUPath -ErrorAction SilentlyContinue).LastWriteTime 

        if ($PSHelpLastUpdate.Month -ne $Now.Month) {

            if ((New-Object System.Security.Principal.WindowsPrincipal([System.Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {

                New-Item -Path $PSLUPath -ItemType File -Force
                
                $null = Start-Job {
                    Update-Module -Force
                    Update-Help -ErrorAction SilentlyContinue
                }

            }
            else {
                Write-Warning -Message 'Aborting PowerShell Module and Help update due to PowerShell not being run as a local administrator!'
            }

        }

    }   

    
    try {
        $Book = Invoke-WebRequest -Uri https://www.packtpub.com/packt/offers/free-learning/ -ErrorAction Stop
    }
    catch [System.NotSupportedException] {
        Write-Warning -Message "Internet Explorer engine not available or its first-launch configuration is not complete."
    }
    catch {
        Write-Warning -Message 'An unknown error has occurred.'
    }

    if ($Book) {
        Write-Host 'The Packt Publishing free learning eBook of the day is: ' -ForegroundColor Cyan -NoNewline
        Write-Host "'$($Book.ParsedHtml.getElementsByTagName('H2')[0].InnerHTML.Trim())'" -ForegroundColor Yellow    
    }

}

$Global:ProgressPreference = 'Continue'
