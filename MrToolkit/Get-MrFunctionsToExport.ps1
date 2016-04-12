function Get-MrFunctionsToExport {

    [CmdletBinding()]
    param (
        [ValidateScript({
          If (Test-Path -Path $_ -PathType Container) {
            $True
          }
          else {
            Throw "'$_' is not a valid directory."
          }
        })]
        [string]$Path = (Get-Location),

        [string]$Exclude = '*profile.ps1',

        [switch]$Recurse,

        [switch]$Simple
    )

    $Params = @{
        Exclude = $Exclude
    }

    if ($PSBoundParameters.Recurse) {
        $Params.Recurse = $true
    }

    $results = Get-ChildItem -Path "$Path\*.ps1" @Params |
               Select-Object -ExpandProperty BaseName    
    
    if ((-not($PSBoundParameters.Simple)) -and $results) {
        $results = $results -join "', '"
        Write-Output "'$results'"
    }        
    elseif ($results) {
        Write-Output $results
    }
    
}