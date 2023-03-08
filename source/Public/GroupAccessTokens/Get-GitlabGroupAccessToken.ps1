# https://docs.gitlab.com/ee/api/group_access_tokens.html#list-group-access-tokens
function Get-GitlabGroupAccessToken
{
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        $GroupId,

        [Parameter(Position = 1)]
        [string]
        $TokenId,

        [Parameter()]
        [string]
        $SiteUrl,

        [Parameter()]
        [switch]
        $WhatIf
    )

    $Resource = "groups/$GroupId/access_tokens"
    if ($TokenId)
    {
        $Resource += "/$TokenId"
    }

    Invoke-GitlabApi -HttpMethod 'GET' -Path $Resource -SiteUrl $SiteUrl -WhatIf:$WhatIf | New-WrapperObject 'Gitlab.AccessToken'
}
