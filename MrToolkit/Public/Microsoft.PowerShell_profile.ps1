$Now = Get-Date
$Date = Get-Date -Month $Now.Month -Day 1
    
while ($Date.DayOfWeek -ne 'Tuesday') {$Date = $Date.AddDays(1)}
        
if ($Date.ToShortDateString() -eq $Now.ToShortDateString()) {
    
    $Global:ProgressPreference = 'SilentlyContinue'

        $PSLUPath = "$env:ProgramFiles\WindowsPowerShell\Configuration\pshelp-lastupdated.txt"

        $PSHelpLastUpdate = (Get-ChildItem -Path $PSLUPath -ErrorAction SilentlyContinue).LastWriteTime 

        if ($PSHelpLastUpdate.Month -ne $Now.Month) {

            if ((New-Object System.Security.Principal.WindowsPrincipal([System.Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {

                if (Test-NetConnection -ComputerName bing.com -Port 80 -InformationLevel Quiet -ErrorAction SilentlyContinue -WarningAction SilentlyContinue) {

                    New-Item -Path $PSLUPath -ItemType File -Force | Out-Null
                
                    Start-Job {
                        Update-Module -Force
                        Update-Help -ErrorAction SilentlyContinue
                    } | Out-Null

                }

            }
            else {
                Write-Warning -Message 'Aborting PowerShell Module and Help update due to PowerShell not being run as a local administrator!'
            }

    }

    $Global:ProgressPreference = 'Continue'

}

$StartupVars = @()
$StartupVars = Get-Variable | Select-Object -ExpandProperty Name
