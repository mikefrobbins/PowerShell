function Get-MrHash {
    [CmdletBinding()]
    param (
        [string]$String,
        
        [ValidateSet('MD5', 'SHA1')]        
        [string]$Algorithm = 'MD5'
    )

    Add-Type -AssemblyName System.Web
    [System.Web.Security.FormsAuthentication]::HashPasswordForStoringInConfigFile($String, $Algorithm)

}