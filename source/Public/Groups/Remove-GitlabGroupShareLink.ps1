
# https://docs.gitlab.com/ee/api/groups.html#delete-link-sharing-group-with-another-group

function Remove-GitlabGroupShareLink
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]
        $GroupId,

        [Parameter(Mandatory = $true, Position = 1)]
        [string]
        $GroupShareId,

        [Parameter()]
        [string]
        $SiteUrl,

        [switch]
        [Parameter()]
        $WhatIf
    )

    $GroupId = $GroupId | ConvertTo-UrlEncoded

    $null = Invoke-GitlabApi DELETE "groups/$GroupId/share/$GroupShareId" -SiteUrl $SiteUrl -WhatIf:$WhatIf
}
