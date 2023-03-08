
# https://docs.gitlab.com/ee/api/group_level_variables.html#list-group-variables
function Get-GitlabGroupVariable
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        $GroupId,

        [Parameter(Position=1)]
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

    if ($Key)
    {
        Invoke-GitlabApi -HttpMethod 'GET' -Path "groups/$GroupId/variables/$Key" -SiteUrl $SiteUrl -WhatIf:$WhatIf | New-WrapperObject 'Gitlab.Variable'
    }
    else
    {
        Invoke-GitlabApi -HttpMethod 'GET' -Path "groups/$GroupId/variables" -SiteUrl $SiteUrl -WhatIf:$WhatIf | New-WrapperObject 'Gitlab.Variable'
    }
}
