
#https://docs.gitlab.com/ee/api/pipeline_schedules.html#pipeline-schedule-variables
# This behavior isn't part of the api, but a nested structure on getting a PipelineSchedule itself JUST by Id
function Get-GitlabPipelineScheduleVariable
{
    param
    (
        [Parameter()]
        [string]
        $ProjectId="." ,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [int]
        $PipelineScheduleId,

        [Parameter()]
        $Key,

        [Parameter()]
        [string]
        $SiteUrl,

        [Parameter()]
        [switch]
        $WhatIf
    )

    $Project = Get-GitlabProject $ProjectId -SiteUrl $SiteUrl
    $PipelineSchedule = Get-GitlabPipelineSchedule -ProjectId $Project.Id -PipelineScheduleId $PipelineScheduleId

    $Wrapper = $PipelineSchedule.Variables | New-WrapperObject "Gitlab.PipelineScheduleVariable"
    $Wrapper | Add-Member -MemberType 'NoteProperty' -Name 'ProjectId' -Value $Project.Id
    $Wrapper | Add-Member -MemberType 'NoteProperty' -Name 'PipelineScheduleId' -Value $PipelineSchedule.Id

    if ($Key)
    {
        $Wrapper = $Wrapper | Where-Object { $_.Key -eq $Key }
    }

    $Wrapper
}
