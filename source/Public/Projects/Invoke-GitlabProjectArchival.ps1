
# https://docs.gitlab.com/ee/api/projects.html#archive-a-project

function Invoke-GitlabProjectArchival
{
    [Alias('Archive-GitlabProject')]
    [CmdletBinding(DefaultParameterSetName = 'ByProjectId')]
    param
    (
        [Parameter(ValueFromPipeline = $true, ParameterSetName = 'ByProject')]
        $Project,

        [Parameter(ParameterSetName = 'ByProjectId')]
        [string]
        $ProjectId = '.',

        [Parameter()]
        [string]
        $SiteUrl,

        [Parameter()]
        [switch]
        $WhatIf
    )

    Process
    {
        if ($PSCmdlet.ParameterSetName -eq 'ByProjectId')
        {
            $Project = $(Get-GitlabProject -ProjectId $ProjectId)
        }

        Invoke-GitlabApi POST "projects/$($Project.Id)/archive" -SiteUrl $SiteUrl -WhatIf:$WhatIf |
            New-WrapperObject 'Gitlab.Project'
    }
}
