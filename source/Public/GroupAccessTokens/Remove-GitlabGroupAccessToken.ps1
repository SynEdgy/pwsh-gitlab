
# https://docs.gitlab.com/ee/api/group_access_tokens.html#revoke-a-group-access-token

function Remove-GitlabGroupAccessToken
{
    [CmdletBinding()]
    [Alias('Revoke-GitlabGroupAccessToken')]
    param
    (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]
        $GroupId,

        [Parameter(Position = 1, Mandatory = $true)]
        [string]
        $TokenId,

        [Parameter()]
        [string]
        $SiteUrl,

        [Parameter()]
        [switch]
        $WhatIf
    )

    $Resource = "groups/$GroupId/access_tokens/$TokenId"

    try
    {
        $null = Invoke-GitlabApi -HttpMethod 'DELETE' -Path $Resource -SiteUrl $SiteUrl -WhatIf:$WhatIf
        Write-Information -InformationAction 'Continue' -MessageData "$TokenId revoked from $GroupId"
    }
    catch
    {
        Write-Error "Error revoking gitlab token from ${GroupId}: $_"
    }
}
