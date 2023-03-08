
# https://docs.gitlab.com/ee/api/group_level_variables.html#remove-variable
function Remove-GitlabGroupVariable
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]
        $GroupId,

        [Parameter(Mandatory = $true, Position = 1)]
        [string]
        $Key,

        [Parameter()]
        [string]
        $SiteUrl,

        [Parameter()]
        [switch]
        $WhatIf
    )

    $GroupId = $GroupId | ConvertTo-UrlEncoded

    $null = Invoke-GitlabApi -HttpMethod 'DELETE' -Path "groups/$GroupId/variables/$Key" -SiteUrl $SiteUrl -WhatIf:$WhatIf
}
