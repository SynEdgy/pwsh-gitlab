
# https://docs.gitlab.com/ee/api/projects.html#unarchive-a-project

function Invoke-GitlabProjectUnarchival
{
    [Alias('Unarchive-GitlabProject')]
    [CmdletBinding(DefaultParameterSetName = 'ByProjectId')]
    param
    (
        [Parameter(ValueFromPipeline = $true, ParameterSetName = 'ByProject')]
        $Project,

        [Parameter(Position = 0)]
        [string]
        $ProjectId = '.',

        [Parameter()]
        [string]
        $SiteUrl,

        [switch]
        [Parameter()]
        $WhatIf
    )

    Process
    {
        if ($PSCmdlet.ParameterSetName -eq 'ByProjectId')
        {
            $Project = $(Get-GitlabProject -ProjectId $ProjectId)
        }

        Invoke-GitlabApi POST "projects/$($Project.Id)/unarchive" -SiteUrl $SiteUrl -WhatIf:$WhatIf |
            New-WrapperObject 'Gitlab.Project'
    }
}
