function Get-MrEsetUpdateVersion {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [string[]]$ComputerName = $env:COMPUTERNAME,
        
        [System.Management.Automation.Credential()]$Credential = [System.Management.Automation.PSCredential]::Empty
    )

    $Params = @{}
    if ($PSBoundParameters.Credential){
        $Params.Credential = $Credential
    }

    $Results = Invoke-Command -ComputerName $ComputerName {
        Get-ItemProperty -Path 'HKLM:\SOFTWARE\ESET\ESET Security\CurrentVersion\Info' 2>&1 
    } @Params

    foreach ($Result in $Results) {
        [pscustomobject]@{
            ComputerName = $Result.PSComputerName
            ProductName = $Result.ProductName
            ScannerVersion = $Result.ScannerVersionId
            LastUpdate = if ($Result.ScannerVersion) {([datetime]::ParseExact($Result.ScannerVersion -replace '^.*\(|\)', 'yyyyMMdd', $null)).ToShortDateString()}
        }
    }
    
}