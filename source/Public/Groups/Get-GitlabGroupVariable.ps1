
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

        [switch]
        [Parameter()]
        $WhatIf
    )

    $GroupId = $GroupId | ConvertTo-UrlEncoded

    if ($Key)
    {
        Invoke-GitlabApi GET "groups/$GroupId/variables/$Key" -SiteUrl $SiteUrl -WhatIf:$WhatIf | New-WrapperObject 'Gitlab.Variable'
    }
    else
    {
        Invoke-GitlabApi GET "groups/$GroupId/variables" -SiteUrl $SiteUrl -WhatIf:$WhatIf | New-WrapperObject 'Gitlab.Variable'
    }
}
