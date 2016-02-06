Set-Location -Path $env:SystemDrive\
Clear-Host

$Error.Clear()
Import-Module -Name posh-git -ErrorAction SilentlyContinue

if (-not($Error[0])) {
    $GitPromptSettings.BeforeText = '('
    $GitPromptSettings.BeforeForegroundColor = [ConsoleColor]::Cyan
    $GitPromptSettings.AfterText = ')'
    $GitPromptSettings.AfterForegroundColor = [ConsoleColor]::Cyan

    function prompt {

        if (-not (Get-GitDirectory)) {
            "PS $($executionContext.SessionState.Path.CurrentLocation)$('>' * ($nestedPromptLevel + 1)) "   
        }
        else {
            $realLASTEXITCODE = $LASTEXITCODE

            Write-Host 'PS ' -ForegroundColor Green -NoNewline
            Write-Host "$($executionContext.SessionState.Path.CurrentLocation) " -ForegroundColor Yellow -NoNewline

            Write-VcsStatus

            $LASTEXITCODE = $realLASTEXITCODE
            return "`n$('$' * ($nestedPromptLevel + 1)) "   
        }

    }

}
else {
    Write-Warning -Message 'Unable to load the Posh-Git PowerShell Module'
}
