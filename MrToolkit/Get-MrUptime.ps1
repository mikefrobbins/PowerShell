function Get-MrUptime {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        [Microsoft.Management.Infrastructure.CimSession[]]$CimSession
    )

    PROCESS {
        [array]$CimSessions += $CimSession
    }
    
    END {
        Get-CimInstance -CimSession $CimSessions -ClassName Win32_OperatingSystem -Property LocalDateTime, LastBootUpTime |
        Select-Object -Property PSComputerName, @{label='Uptime';expression={$_.LocalDateTime - $_.LastBootUpTime}}

        $CimSessions | Remove-CimSession -ErrorAction SilentlyContinue
    }

}
