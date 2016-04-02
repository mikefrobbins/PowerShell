function Expand-MrZipFile {

<#
.SYNOPSIS
   Expand-MrZipFile is a function which extracts the contents of a zip file.

.DESCRIPTION
   Expand-MrZipFile is a function which extracts the contents of a zip file specified via the -File parameter to the
    location specified via the -Destination parameter. This function first checks to see if the .NET Framework 4.5
    is installed and uses it for the unzipping process, otherwise COM is used.

.PARAMETER File
    The complete path and name of the zip file in this format: C:\zipfiles\myzipfile.zip 
 
.PARAMETER Destination
    The destination folder to extract the contents of the zip file to. If a path is no specified, the current path
    is used.

.PARAMETER ForceCOM
    Switch parameter to force the use of COM for the extraction even if the .NET Framework 4.5 is present.

.EXAMPLE
   Expand-MrZipFile -File C:\zipfiles\AdventureWorks2012_Database.zip -Destination C:\databases\

.EXAMPLE
   Expand-MrZipFile -File C:\zipfiles\AdventureWorks2012_Database.zip -Destination C:\databases\ -ForceCOM

.EXAMPLE
   'C:\zipfiles\AdventureWorks2012_Database.zip' | Expand-MrZipFile

.EXAMPLE
    Get-ChildItem -Path C:\zipfiles | ForEach-Object {$_.fullname | Expand-MrZipFile -Destination C:\databases}

.INPUTS
   String

.OUTPUTS
   None

.NOTES
   Author:  Mike F Robbins
   Website: http://mikefrobbins.com
   Twitter: @mikefrobbins

#>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true)]
        [ValidateScript({
            If ((Test-Path -Path $_ -PathType Leaf) -and ($_ -like "*.zip")) {
                $true
            }
            else {
                Throw "$_ is not a valid zip file. Enter in 'c:\folder\file.zip' format"
            }
        })]
        [string]$File,

        [ValidateNotNullOrEmpty()]
        [ValidateScript({
            If (Test-Path -Path $_ -PathType Container) {
                $true
            }
            else {
                Throw "$_ is not a valid destination folder. Enter in 'c:\destination' format"
            }
        })]
        [string]$Destination = (Get-Location).Path,

        [switch]$ForceCOM
    )
    
    If (-not $ForceCOM -and ($PSVersionTable.PSVersion.Major -ge 3) -and
       ((Get-ItemProperty -Path "HKLM:\Software\Microsoft\NET Framework Setup\NDP\v4\Full" -ErrorAction SilentlyContinue).Version -like "4.5*" -or
       (Get-ItemProperty -Path "HKLM:\Software\Microsoft\NET Framework Setup\NDP\v4\Client" -ErrorAction SilentlyContinue).Version -like "4.5*")) {

        Write-Verbose -Message "Attempting to Unzip $File to location $Destination using .NET 4.5"

        try {
            [System.Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem") | Out-Null
            [System.IO.Compression.ZipFile]::ExtractToDirectory("$File", "$Destination")
        }
        catch {
            Write-Warning -Message "Unexpected Error. Error details: $_.Exception.Message"
        }
        
    }
    else {

        Write-Verbose -Message "Attempting to Unzip $File to location $Destination using COM"

        try {
            $shell = New-Object -ComObject Shell.Application
            $shell.Namespace($destination).copyhere(($shell.NameSpace($file)).items())
        }
        catch {
            Write-Warning -Message "Unexpected Error. Error details: $_.Exception.Message"
        }

    }

}