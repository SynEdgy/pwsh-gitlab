
# https://docs.gitlab.com/ee/api/pipelines.html#get-variables-of-a-pipeline
function Get-GitlabPipelineVariable
{
    param
    (
        [Parameter()]
        [string]
        $ProjectId = '.',

        [Parameter(Position = 0, Mandatory = $true)]
        [string]
        $PipelineId,

        [Parameter()]
        [string]
        $SiteUrl,

        [Parameter()]
        [switch]
        $WhatIf
    )

    $Project = Get-GitlabProject $ProjectId

    Invoke-GitlabApi -HttpMethod 'GET' -Path "projects/$($Project.Id)/pipelines/$PipelineId/variables" -SiteUrl $SiteUrl -WhatIf:$WhatIf | New-WrapperObject
}
