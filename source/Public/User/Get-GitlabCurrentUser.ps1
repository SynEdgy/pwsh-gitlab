
function Get-GitlabCurrentUser
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [string]
        $SiteUrl
    )

    Get-GitlabUser -Me -SiteUrl $SiteUrl
}
