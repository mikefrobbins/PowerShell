function Get-MrExceptionType {

    [CmdletBinding()]
    param (
        [ValidateRange(1,256)]
        [int]$Count = 1
    )
    
    for ($i = 0; $i -lt $Count; $i++) {

        if ($Error[$i]) {
            [PSCustomObject]@{
                ErrorNumber = "`$Error[$i]"
                ExceptionType = if ($Error[$i].exception) {$Error[$i].Exception.GetType().FullName}
            }
        }

    }
    
}