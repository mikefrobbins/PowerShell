#Requires -Version 3.0
#Add 'Requires -Modules Hyper-V' if used without the script module
function Get-MrVHDChain {
    [CmdletBinding()]
    param(
        [string]$ComputerName = $env:COMPUTERNAME,
        [string[]]$Name = '*'
    )
    try {
        $VMs = Get-VM -ComputerName $ComputerName -Name $Name -ErrorAction Stop
    }
    catch {
        Write-Warning $_.Exception.Message
    }
    foreach ($vm in $VMs){
        $VHDs = ($vm).harddrives.path
        foreach ($vhd in $VHDs){
            Clear-Variable VHDType -ErrorAction SilentlyContinue
            try {
                $VHDInfo = $vhd | Get-VHD -ComputerName $ComputerName -ErrorAction Stop
            }
            catch {
                $VHDType = 'Error'
                $VHDPath = $vhd
                Write-Verbose $_.Exception.Message
            }
            $i = 1
            $problem = $false
            while (($VHDInfo.parentpath -or $i -eq 1) -and (-not($problem))){
                If ($VHDType -ne 'Error' -and $i -gt 1){
                    try {
                        $VHDInfo = $VHDInfo.ParentPath | Get-VHD -ComputerName $ComputerName -ErrorAction Stop
                    }
                    catch {
                        $VHDType = 'Error'
                        $VHDPath = $VHDInfo.parentpath
                        Write-Verbose $_.Exception.Message
                    }
                }
                if ($VHDType -ne 'Error'){
                    $VHDType = $VHDInfo.VhdType
                    $VHDPath = $VHDInfo.path
                }
                else {
                    $problem = $true
                }
                [pscustomobject]@{
                    Name = $vm.name
                    VHDNumber = $i
                    VHDType = $VHDType
                    VHD = $VHDPath
                }
                $i++
            }
        }
    }
}