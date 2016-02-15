#Requires -Version 4.0 -Modules Posh-Git
function Update-MrGitRepository {
    [CmdletBinding()]
    param ()

    $Location = Get-Location
    if (Get-GitDirectory) {
        $Repository = Split-Path -Path (git.exe rev-parse --show-toplevel) -Leaf
    }
    else {
        throw "$Location is not part of a Git repsoitory."
    }

    if ((git.exe remote) -contains 'origin') {        
        $originURL = (git.exe remote -v) -match '^origin.*fetch\)$' -replace '^origin\s*|\s*\(fetch\)$'
    }
    else {
        throw "Origin not setup for Git '$Repository' repository"
    }    
    
    if ((Invoke-WebRequest -Uri $($originURL)).StatusCode -ne 200) {     
        Write-Warning -Message 'An unexpected error has occured'
    }
    else {        
        $currentBranch = git.exe symbolic-ref --short HEAD
        $localCommit = git.exe rev-list --all -n1
        $remoteCommit = (git.exe ls-remote origin $currentBranch) -replace '\s.*$'
        
        if ($localCommit -ne $remoteCommit){
            git.exe fetch
        }

    }
}