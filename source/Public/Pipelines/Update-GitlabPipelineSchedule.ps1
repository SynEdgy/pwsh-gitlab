
# https://docs.gitlab.com/ee/api/pipeline_schedules.html#edit-a-pipeline-schedule
function Update-GitlabPipelineSchedule
{
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]
        $ProjectId = '.',

        [Parameter(ValueFromPipelineByPropertyName = $true, Mandatory = $true)]
        [int]
        $PipelineScheduleId,

        [Parameter()]
        [string]
        $Description,

        [Parameter()]
        [Alias("Branch")]
        [string]
        $Ref,

        [Parameter()]
        [string]
        $Cron,

        [Parameter()]
        [ValidateSet($null, 'America/Los_Angeles')] #TODO: Why is that limited to those 2 TZ?
        [string]
        $CronTimezone,

        [Parameter()]
        [bool]
        $Active,

        [Parameter()]
        [string]
        $SiteUrl,

        [switch]
        [Parameter()]
        $WhatIf
    )

    $Project = Get-GitlabProject -SiteUrl $SiteUrl

    $GitlabApiArguments = @{
        HttpMethod = 'PUT'
        Path       = "projects/$($Project.Id)/pipeline_schedules/$PipelineScheduleId"
        Body       = @{}
        SiteUrl    = $SiteUrl
    }

    if ($PSBoundParameters.ContainsKey("Active"))
    {
        $GitlabApiArguments.Body.active = $Active.ToString().ToLower()
    }

    if ($Description)
    {
        $GitlabApiArguments.Body.description = $Description
    }

    if ($Ref)
    {
        $GitlabApiArguments.Body.ref = $Ref
    }

    if ($Cron)
    {
        $GitlabApiArguments.Body.cron = $Cron
    }

    if ($CronTimezone)
    {
        $GitlabApiArguments.Body.cron_timezone = $CronTimezone
    }

    Invoke-GitlabApi @GitlabApiArguments -WhatIf:$WhatIf | New-WrapperObject 'Gitlab.PipelineSchedule'
}
