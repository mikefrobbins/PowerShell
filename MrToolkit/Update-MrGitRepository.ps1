#Requires -Version 4.0
#Add 'Requires -Modules Posh-Git' if used without the script module
function Update-MrGitRepository {

    [CmdletBinding(SupportsShouldProcess,
                   ConfirmImpact='Medium')]
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
    
    if ((Invoke-WebRequest -Uri $($originURL) -TimeoutSec 15).StatusCode -ne 200) {     
        Write-Warning -Message "Unable to communicate with remote origin '$originURL'"
    }
    else {        
        $currentBranch = git.exe symbolic-ref --short HEAD
        $localCommit = git.exe rev-list --all -n1
        $remoteCommit = (git.exe ls-remote origin $currentBranch) -replace '\s.*$'
        
        if ($localCommit -ne $remoteCommit){

            if ($PSCmdlet.ShouldProcess($currentBranch,'Fetch')) {
                git.exe fetch
            }

        }
        else {
            "Local '$currentBranch' branch of the '$Repository' repository is already up-to-date with '$originURL'."
        }

    }

}