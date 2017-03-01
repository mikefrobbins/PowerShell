#Requires -Version 3.0 -Modules MrGeo
function New-MrPlanetPowerShellAuthor {
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