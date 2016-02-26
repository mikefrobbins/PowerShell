#Requires -Version 3.0
#Requires -Modules ActiveDirectory
function Compare-MrADGroup {

<#
.SYNOPSIS
    Compares the groups of a the specified Active Directory users.

.DESCRIPTION
    Compare-MrADGroup is a function that retrieves a list of all the Active
    Directory groups that the specified Active Directory users are a member
    of. It determines what groups are common between the users based on
    membership of 50% or more of the specified users. It then compares the
    specified users group membership to the list of common groups and returns
    a list of users whose group membership differentiates from that list. A
    minus (-) in the status column means the user is not a member of a common
    group and a plus (+) means the user is a member of an additional group.

.PARAMETER UserName
    The Active Directory user(s) account object to compare. Can be specified
    in the form or SamAccountName, Distinguished Name, or GUID. This parameter
    is mandatory.

.PARAMETER IncludeEqual
    Switch parameter to include common groups that the specified user is a
    member of. An equals (=) sign means the user is a member of a common group.

.EXAMPLE
     Compare-MrADGroup -UserName 'jleverling', 'lcallahan', 'mpeacock'

.EXAMPLE
     'jleverling', 'lcallahan', 'mpeacock' | Compare-MrADGroup -IncludeEqual

.EXAMPLE
     Get-ADUser -Filter {Department -eq 'Sales' -and Enabled -eq 'True'} |
     Compare-MrADGroup

.INPUTS
    String

.OUTPUTS
    PSCustomObject

.NOTES
    Author:  Mike F Robbins
    Website: http://mikefrobbins.com
    Twitter: @mikefrobbins
#>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory,
                   ValueFromPipeline)]
        [string[]]$UserName,

        [switch]$IncludeEqual
    )

    BEGIN {
        $Params = @{}

        If ($PSBoundParameters['IncludeEqual']) {
            $Params.IncludeEqual = $true
        }
    }

    PROCESS {
        foreach ($name in $UserName) {
            try {
                Write-Verbose -Message "Attempting to query Active Directory of user: '$name'."
                [array]$users += Get-ADUser -Identity $name -Properties MemberOf -ErrorAction Stop
            }
            catch {
                Write-Warning -Message "An error occured. Error Details: $_.Exception.Message"
            }
        }
    }

    END {
        Write-Verbose -Message "The `$users variable currently contains $($users.Count) items."

        $commongroups = ($groups = $users |
        Select-Object -ExpandProperty MemberOf |
        Group-Object) |
        Where-Object Count -ge ($users.Count / 2) |
        Select-Object -ExpandProperty Name
        
        Write-Verbose -Message "There are $($commongroups.Count) groups with 50% or more of the specified users in them."
        
        foreach ($user in $users) {
            Write-Verbose -Message "Checking user: '$($user.SamAccountName)' for group differences."

            $differences = Compare-Object -ReferenceObject $commongroups -DifferenceObject $user.MemberOf @Params

            foreach ($difference in $differences) {
                [PSCustomObject]@{
                    UserName = $user.SamAccountName
                    GroupName = $difference.InputObject -replace '^CN=|,.*$'
                    Status = switch ($difference.SideIndicator){'<='{'-';break}'=>'{'+';break}'=='{'=';break}}
                    'RatioOfUsersInGroup(%)' = ($groups | Where-Object name -eq $difference.InputObject).Count / $users.Count * 100 -as [int]
                }
            }
        }
    }
}