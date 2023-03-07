
# https://docs.gitlab.com/ee/api/pipeline_schedules.html#delete-a-pipeline-schedule
function Remove-GitlabPipelineSchedule
{
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]
        $ProjectId = '.',

        [Parameter(ValueFromPipelineByPropertyName = $true, Mandatory = $true)]
        [Alias('Id')]
        [int]
        $PipelineScheduleId,

        [Parameter()]
        [string]
        $SiteUrl,

        [switch]
        [Parameter()]
        $WhatIf
    )

    $Project = Get-GitlabProject -SiteUrl $SiteUrl

    $GitlabApiArguments = @{
        HttpMethod = 'DELETE'
        Path       = "projects/$($Project.Id)/pipeline_schedules/$PipelineScheduleId"
        SiteUrl    = $SiteUrl
    }

    Invoke-GitlabApi @GitlabApiArguments -WhatIf:$WhatIf
}
