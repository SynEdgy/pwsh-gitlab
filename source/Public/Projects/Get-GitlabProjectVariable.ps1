
# https://docs.gitlab.com/ee/api/project_level_variables.html#list-project-variables

function Get-GitlabProjectVariable
{
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]
        $ProjectId = '.',

        [Parameter(Position = 0)]
        [string]
        $Key,

        [Parameter()]
        [string]
        $SiteUrl,

        [Parameter()]
        [switch]
        $WhatIf
    )

    $Project = Get-GitlabProject $ProjectId

    if ($Key)
    {
        Invoke-GitlabApi -HttpMethod 'GET' -Path "projects/$($Project.Id)/variables/$Key" -SiteUrl $SiteUrl -WhatIf:$WhatIf | New-WrapperObject 'Gitlab.Variable'
    }
    else
    {
        Invoke-GitlabApi -HttpMethod 'GET' -Path "projects/$($Project.Id)/variables" -SiteUrl $SiteUrl -WhatIf:$WhatIf | New-WrapperObject 'Gitlab.Variable'
    }
}
