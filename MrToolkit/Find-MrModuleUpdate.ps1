function Find-MrModuleUpdate {
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
