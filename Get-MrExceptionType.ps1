function Get-MrExceptionType {

    [CmdletBinding()]
    param (
        [ValidateRange(1,256)]
        [int]$Count = 1
    )
    
    if ($Error.Count -ge 1) {

        if ($Count -gt $Error.Count) {
            $Count = $Error.Count
        }

        for ($i = 0; $i -lt $Count; $i++) {

            [PSCustomObject]@{
                ErrorNumber = "`$Error[$i]"
                ExceptionType = if ($Error[$i].exception) {$Error[$i].Exception.GetType().FullName}
            }

        }

    }
    else {
        Write-Warning -Message 'No errors have been generated for the current PowerShell session.'
    }
    
}