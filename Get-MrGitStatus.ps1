#Requires -Version 4.0 -Modules Posh-Git
function Get-MrGitStatus {
    [CmdletBinding()]
    param ()

    $Location = Get-Location
    if (Get-GitDirectory) {
        $Repository = Split-Path -Path (git rev-parse --show-toplevel) -Leaf
    }
    else {
        throw "$Location is not part of a Git repsoitory."
    }

    if ((git remote) -contains 'origin') {        
        $originURL = (git remote -v) -match '^origin.*fetch\)$' -replace '^origin\s*|\s*\(fetch\)$'
    }
    else {
        throw "Origin not setup for Git '$Repository' repository"
    }
    
    
    if (-not(Test-NetConnection -ComputerName $originURL -Port 443 -InformationLevel Quiet)) {     
        Write-Warning -Message 'An unexpected error has occured'
    }
    else {        
        $currentBranch = git symbolic-ref --short HEAD
        $localCommit = git rev-list --all -n1
        $remoteCommit = (git ls-remote origin $currentBranch) -replace '\s.*$'
        
        if ($localCommit -ne $remoteCommit){
            $Status = $false
        }
        else {
            $Status = $true
        }

        [pscustomobject]@{
            RepositoryName = $Repository
            CurrentBranch = $currentBranch
            UpToDate = $Status
        }
    }
}