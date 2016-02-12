function Get-MrGitHubRepositoryInfo {

    [CmdletBinding()]
    [OutputType('Mr.RepositoryInfo')]
    param (
        [Parameter(Mandatory)]
        [string[]]$UserName,

        [ValidateNotNullOrEmpty()]
        [string]$RepositoryName = '*'
    )

    foreach ($User in $UserName) {
        Write-Verbose -Message "Querying GitHub repository information for user: '$User'"
        $json = Invoke-RestMethod -Uri "https://api.github.com/users/$User/repos"
        
        if ($PSBoundParameters.RepositoryName) {
            Write-Verbose -Message "Limiting results where repository name like '$RepositoryName'"
            $json = $json | Where-Object Name -like $RepositoryName
        }

        foreach ($j in $json) {
        
            [pscustomobject] @{
                Name = $j.name
                Owner = $j.owner.login                
                Description = $j.description
                URL = $j.html_url
                GitURL = $j.clone_url
                Language = $j.language
                DefaultBranch = $j.default_branch
                Private = $j.private
                Fork = $j.fork
                Stargazers = $j.stargazers_count
                Watchers = $j.watchers_count                
                Forks = $j.forks_count
                OpenIssues = $j.open_issues_count                
                Created = $j.created_at -as [datetime]               
                Updated = $j.updated_at -as [datetime]
                Pushed = $j.pushed_at -as [datetime]
                PSTypeName = 'Mr.RepositoryInfo'
            }
        
        }

    }

}