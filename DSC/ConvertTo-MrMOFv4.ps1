#Requires -Version 4.0
function ConvertTo-MrMOFv4 {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateScript({Test-Path $_ -PathType Leaf -Include *.mof})]
        [Alias('FullName')]
        [string[]]$Path,

        [Parameter(DontShow)]
        [ValidateNotNullorEmpty()]
        [string]$Pattern = '^\sName=.*;$|^\sConfigurationName\s=.*;$'
    )

    PROCESS {
        foreach ($file in $Path) {
            
            $mof = Get-Content -Path $file
            
            if ($mof -match $Pattern) {
                Write-Verbose -Message "PowerShell v4 compatibility problems were found in file: $file"

                try {
                    $mof -replace $Pattern |
                    Set-Content -Path $file -Force -ErrorAction Stop
                }
                catch {
                    Write-Warning -Message "An error has occurred. Error details: $_.Exception.Message"
                }
                finally {
                    if ((Get-Content -Path $file) -notmatch $Pattern) {
                        Write-Verbose -Message "The file: $file was successfully modified."
                    }
                    else {
                        Write-Verbose -Message "Attempt to modify the file: $file was unsuccessful."
                    }
                }
            }
        }
    }
}