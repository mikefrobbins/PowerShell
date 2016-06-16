#Requires -Version 3.0 -Modules PowerShellGet
function Find-MrModuleUpdate {

<#
.SYNOPSIS
    Finds updates for installed modules from an online gallery that matches the specified criteria.
 
.DESCRIPTION
    Find-MrModuleUpdate is a PowerShell advanced function that finds updates from an online gallery for locally installed modules
    regardless of whether or not they were originally installed from an online gallery or from the same online gallery where the
    update is found. 
 
.PARAMETER Name
    Specifies the names of one or more modules to search for.

.PARAMETER Scope
    Specifies the search scope of the installed modules. The acceptable values for this parameter are: AllUsers and CurrentUser.
 
.EXAMPLE
     Find-MrModuleUpdate

.EXAMPLE
     Find-MrModuleUpdate -Name PSScriptAnalyzer, PSVersion

.EXAMPLE
     Find-MrModuleUpdate -Scope CurrentUser

.EXAMPLE
     Find-MrModuleUpdate -Name PSScriptAnalyzer, PSVersion -Scope CurrentUser
 
.INPUTS
    None
 
.OUTPUTS
    Mr.ModuleUpdate
 
.NOTES
    Author:  Mike F Robbins
    Website: http://mikefrobbins.com
    Twitter: @mikefrobbins
#>

    [CmdletBinding()]
    [OutputType('Mr.ModuleUpdate')]
    param (
        [ValidateNotNullOrEmpty()]
        [string[]]$Name,

        [ValidateSet('AllUsers', 'CurrentUser')]
        [string]$Scope
    )

    $AllUsersPath = "$env:ProgramFiles\WindowsPowerShell\Modules\*"
    $CurrentUserPath = "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\*"

    switch ($Scope) {
        'AllUsers' {$Path = $AllUsersPath; break}
        'CurrentUser' {$Path = $CurrentUserPath; break}
        Default {$Path = $AllUsersPath, $CurrentUserPath}
    }

    $Params = @{
        ListAvailable = $true
    }

    if ($PSBoundParameters.Name) {
        $Params.Name = $Name
    }

    $Modules = Get-Module @Params

    foreach ($p in $Path) {
    
        $ScopedModules = $Modules |
        Where-Object ModuleBase -like $p |
        Sort-Object -Property Name, Version -Descending |
        Get-Unique

        foreach ($Module in $ScopedModules) {
            
            Remove-Variable -Name InstallInfo -ErrorAction SilentlyContinue
            $Repo = Find-Module -Name $Module.Name -ErrorAction SilentlyContinue

            if ($Repo) {
                $Diff = Compare-Object -ReferenceObject $Module -DifferenceObject $Repo -Property Name, Version |
                        Where-Object SideIndicator -eq '=>'

                if ($Diff) {
                    $PSGetModuleInfoPath = "$($Module.ModuleBase)\PSGetModuleInfo.xml"

                    if (Test-Path -Path $PSGetModuleInfoPath) {
                        $InstallInfo = Import-Clixml -Path $PSGetModuleInfoPath
                    }

                    switch ($Module.ModuleBase) {
                        {$_ -like $AllUsersPath} {$Location = 'AllUsers'; break}
                        {$_ -like $CurrentUserPath} {$Location = 'CurrentUser'; break}
                        Default {Throw 'An unexpected error has occured.'}
                    }

                    [pscustomobject]@{
                        Name = $Module.Name
                        InstalledVersion = $Module.Version
                        InstalledLocation = $Location
                        Repository = $Repo.Repository
                        RepositoryVersion = $Diff.Version
                        InstalledFromRepository = $InstallInfo.Repository
                        PSTypeName = 'Mr.ModuleUpdate'
                    }

                }

            }
        
        }
    
    }

}
