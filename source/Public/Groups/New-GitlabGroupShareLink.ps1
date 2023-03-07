

# https://docs.gitlab.com/ee/api/groups.html#create-a-link-to-share-a-group-with-another-group

function New-GitlabGroupShareLink
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]
        $GroupId,

        [Parameter(Position = 1, Mandatory = $true)]
        [string]
        $GroupShareId,

        [Parameter(Position = 2, Mandatory = $true)]
        [ValidateSet('noaccess','minimalaccess','guest','reporter','developer','maintainer','owner')]
        [string]
        $AccessLevel,

        [Parameter()]
        [ValidateScript({ValidateGitlabDateFormat $_})]
        [string]
        $ExpiresAt,

        [Parameter()]
        [string]
        $SiteUrl,

        [switch]
        [Parameter()]
        $WhatIf
    )

    $GroupId = $GroupId | ConvertTo-UrlEncoded

    $Body = @{
        group_id     = $GroupShareId
        group_access = Get-GitlabMemberAccessLevel $AccessLevel
        expires_at   = $ExpiresAt
    }

    Invoke-GitlabApi POST "groups/$GroupId/share" -Body $Body -SiteUrl $SiteUrl -WhatIf:$WhatIf | New-WrapperObject 'Gitlab.Group'
}
