#Requires -Version 3.0 -Modules MrGeo
function New-MrPlanetPowerShellAuthor {

<#
.SYNOPSIS
    Creates the author information required to add your PowerShell related blog to Planet PowerShell.
 
.DESCRIPTION
    New-MrPlanetPowerShellAuthor is an advanced function that creates the author information required
    to add your PowerShell related blog to Planet PowerShell (http://www.planetpowershell.com/). Planet
    PowerShell is an aggregator of content from PowerShell Community members.
 
.PARAMETER FirstName
    Author's first name.

.PARAMETER LastName
    Author's last name.

.PARAMETER Bio
    Short bio about the author.

.PARAMETER StateOrRegion
    Your geographical location, i.e.: Holland, New York, etc.

.PARAMETER EmailAddress
    Email address. Only enter if you want your email address to be publicly available.

.PARAMETER TwitterHandle
    Twitter handle without the leading @.

.PARAMETER GravatarEmailAddress
    The email address you use at gravatar.com. Entering this causes the picture used at Gravatar.com to
    be used as your author picture on Planet PowerShell. The email address is converted to the MD5 hash
    of the email address string.

.PARAMETER GitHubHandle
    GitHub handle without the leading @.

.PARAMETER BlogUri
    URL of your blog site.

.PARAMETER RssUri
    URL for the RSS feed to your blog site.

.PARAMETER MicrosoftMVP
    Switch parameter. Specify if you're a Microsoft MVP.

.PARAMETER FilterToPowerShell
    Switch parameter. Specify if you blog on more than just PowerShell.

.EXAMPLE
    New-MrPlanetPowerShellAuthor -FirstName Mike -LastName Robbins -Bio 'Microsoft PowerShell MVP and SAPIEN Technologies MVP. Leader & Co-founder of MSPSUG' -StateOrRegion 'Mississippi, USA' -TwitterHandle mikefrobbins -GravatarEmailAddress mikefrobbins@users.noreply.github.com -GitHubHandle mikefrobbins -BlogUri mikefrobbins.com -RssUri mikefrobbins.com/feed -MicrosoftMVP -FilterToPowerShell |
    New-Item -Path C:\GitHub\planetpowershell\src\Firehose.Web\Authors\MikeRobbins.cs

.INPUTS
    None
 
.OUTPUTS
    System.String
 
.NOTES
    Author:  Mike F Robbins
    Website: http://mikefrobbins.com
    Twitter: @mikefrobbins
#>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$FirstName,

        [Parameter(Mandatory)]
        [string]$LastName,

        [string]$Bio,

        [string]$StateOrRegion,

        [string]$EmailAddress,

        [string]$TwitterHandle,

        [string]$GravatarEmailAddress,

        [string]$GitHubHandle,

        [Parameter(Mandatory)]
        [string]$BlogUri,

        [string]$RssUri,

        [switch]$MicrosoftMVP,

        [switch]$FilterToPowerShell
    )

    $BlogUrl = (Test-MrURL -Uri $BlogUri -Detailed).ResponseUri
    
    if ($PSBoundParameters.RssUri) {
        $RssUrl = (Test-MrURL -Uri $RssUri -Detailed).ResponseUri
    }
    
    $GravatarHash = (Get-MrHash -String $GravatarEmailAddress).ToLower()
    $Location = Get-MrGeoInformation
    $GeoLocation = -join ($Location.Latitude, ', ', $Location.Longitude)
    
    if ($MicrosoftMVP) {
        $Interface = 'IAmAMicrosoftMVP'
    }
    else {
        $Interface = 'IAmACommunityMember'
    }

    if ($FilterToPowerShell) {
        $Interface = "$Interface, IFilterMyBlogPosts"

        $SyndicationItem =
@'
public bool Filter(SyndicationItem item)
        {
            return item.Categories.Any(c => c.Name.ToLowerInvariant().Equals("powershell"));
        }
'@
    }

@"
using System;
using System.Collections.Generic;
using System.Linq;
using System.ServiceModel.Syndication;
using System.Web;
using Firehose.Web.Infrastructure;
namespace Firehose.Web.Authors
{
    public class $FirstName$LastName : $Interface
    {
        public string FirstName => `"$FirstName`";
        public string LastName => `"$LastName`";
        public string ShortBioOrTagLine => `"$Bio`";
        public string StateOrRegion => `"$StateOrRegion`";
        public string EmailAddress => `"$EmailAddress`";
        public string TwitterHandle => `"$TwitterHandle`";
        public string GitHubHandle => `"$GitHubHandle`";
        public string GravatarHash => `"$GravatarHash`";
        public GeoPosition Position => new GeoPosition($GeoLocation);

        public Uri WebSite => new Uri(`"$BlogUrl`");
        public IEnumerable<Uri> FeedUris { get { yield return new Uri(`"$RssUrl`"); } }

        $SyndicationItem
    }
}
"@

}