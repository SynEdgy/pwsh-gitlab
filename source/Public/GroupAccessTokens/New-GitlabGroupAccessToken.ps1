
# https://docs.gitlab.com/ee/api/group_access_tokens.html#create-a-group-access-token

function New-GitlabGroupAccessToken
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]
        $GroupId,

        [Parameter(Mandatory = $true)]
        [string]
        $Name,

        [Parameter(Mandatory = $true)]
        [ValidateSet('api', 'read_api', 'read_registry', 'write_registry', 'read_repository', 'write_repository')]
        [string []]
        $Scope,

        [Parameter()]
        [string]
        [ValidateSet('guest', 'reporter', 'developer', 'maintainer', 'owner')]
        $AccessLevel = 'maintainer',

        [Parameter()]
        [switch]
        $CopyToClipboard,

        [Parameter()]
        [string]
        $SiteUrl,

        [Parameter()]
        [switch]
        $WhatIf
    )

    $Response = Invoke-GitlabApi -HttpMethod 'POST' -Path "groups/$GroupId/access_tokens" -Body @{
        name         = $Name
        scopes       = $Scope
        access_level = Get-GitlabMemberAccessLevel $AccessLevel
    } -SiteUrl $SiteUrl -WhatIf:$WhatIf

    if ($CopyToClipboard)
    {
        $Response.token | Set-Clipboard
    }
    else
    {
        $Response
    }
}
