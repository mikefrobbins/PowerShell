function Test-MrFileLock {
    [CmdletBinding()]
    param (
        [ValidateScript({
          If (Test-Path -Path $_ -PathType Leaf) {
            $True
          }
          else {
            Throw "'$($_ -replace '^.*\\')' is not a valid file."
          }
        })]
        [string]$Path
    )

    try {
        $File = [System.IO.File]::Open("$Path", 'Open', 'Read', 'ReadWrite')
        if ($File) {
            $File.Close()
            $false            
        }

    }
    catch {
        Write-Verbose -Message "The file '$($Path -replace '^.*\\')' is locked by a process."
        $true
    }    

}