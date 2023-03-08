
# https://docs.gitlab.com/ee/api/project_level_variables.html#list-project-variables

function Remove-GitlabProjectVariable
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [string]
        $ProjectId = '.',

        [Parameter(Mandatory = $true, Position = 0)]
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

    Invoke-GitlabApi -HttpMethod 'DELETE' -Path "projects/$($Project.Id)/variables/$Key" -SiteUrl $SiteUrl -WhatIf:$WhatIf | Out-Null
}
