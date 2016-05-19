function Invoke-MrPesterToSpeech {
    [CmdletBinding()]
    param (
        [switch]$Quiet
    )

    $Params = @{}
    if ($PSBoundParameters.Quiet) {
        $Params.Quiet = $true
    }

    $Results = Invoke-Pester -PassThru @Params |
    Select-Object -ExpandProperty TestResult

    foreach ($Result in $Results) {
        Write-Output "The unit test named $($Result.Name) has $($Result.Result)." |
        Out-MrSpeech
    }
}