
# wraps Update-GitlabProjectIntegration but with an interface tailored for Slack
# https://docs.gitlab.com/ee/api/integrations.html#createedit-slack-integration
function Enable-GitlabProjectSlackNotification
{
    [CmdletBinding(SupportsShouldProcess = $true, DefaultParameterSetName = 'SpecificEvents')]
    param
    (
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]
        $ProjectId = '.',

        [Parameter(Position = 0, Mandatory = $true)]
        [string]
        $Channel,

        [Parameter()]
        [string]
        $Webhook,

        [Parameter()]
        [string]
        $Username,

        [Parameter()]
        [ValidateSet('all', 'default', 'protected', 'default_and_protected')]
        [string]
        $BranchesToBeNotified = 'default_and_protected',

        [Parameter()]
        [string]
        [ValidateSet($null, 'true', 'false')]
        $NotifyOnlyBrokenPipelines,

        [Parameter()]
        [ValidateSet($null, 'true', 'false')]
        [string]
        $JobEvents,

        [Parameter(ParameterSetName='SpecificEvents', Position=1, Mandatory)]
        [ValidateSet('commit', 'confidential_issue', 'confidential_note', 'deployment', 'issue', 'merge_request', 'note', 'pipeline', 'push', 'tag_push', 'wiki_page')]
        [string []]
        $Enable,

        [Parameter(ParameterSetName='SpecificEvents', Position=1, Mandatory)]
        [ValidateSet('commit', 'confidential_issue', 'confidential_note', 'deployment', 'issue', 'merge_request', 'note', 'pipeline', 'push', 'tag_push', 'wiki_page')]
        [string []]
        $Disable,

        [Parameter(ParameterSetName='AllEvents')]
        [switch]
        $AllEvents,

        [Parameter()]
        [string]
        $SiteUrl
    )

    $Project = Get-GitlabProject $ProjectId -SiteUrl $SiteUrl

    if ($AllEvents)
    {
        $Enable = @('commit', 'confidential_issue', 'confidential_note', 'issue', 'merge_request', 'note', 'pipeline', 'push', 'tag_push', 'wiki_page')
    }

    if (-not $Webhook)
    {
        try
        {
            $Webhook = $(Get-GitlabProjectIntegration -ProjectId $Project.Id -Integration 'slack').Properties.webhook
        }
        catch
        {
            throw "Webhook could not be derived from an existing integration (provide via -Webhook parameter)"
        }
    }

    $Settings = @{
        webhook = $Webhook
    }

    if ($PSBoundParameters.ContainsKey('Username'))
    {
        $Settings.username = $Username
    }

    if ($BranchesToBeNotified)
    {
        $Settings.branches_to_be_notified = $BranchesToBeNotified
    }

    if ($NotifyOnlyBrokenPipelines)
    {
        $Settings.notify_only_broken_pipelines = $NotifyOnlyBrokenPipelines
    }

    if ($JobEvents)
    {
        $Settings.job_events = $JobEvents
    }

    $ShouldPluralize = @(
        'confidential_issue',
        'issue',
        'merge_request'
    )

    $Enable | ForEach-Object {
        $Settings."$_`_channel"  = $Channel
        $EventProperty           = $ShouldPluralize.Contains($_) ? "$($_)s_events" : "$($_)_events"
        $Settings.$EventProperty = 'true'
    }

    $Disable | ForEach-Object {
        $Settings."$_`_channel"  = $Channel
        $EventProperty           = $ShouldPluralize.Contains($_) ? "$($_)s_events" : "$($_)_events"
        $Settings.$EventProperty = 'false'
    }

    if ($PSCmdlet.ShouldProcess("slack notifications for $($Project.PathWithNamespace)", "notify $Channel ($($Settings | ConvertTo-Json)))"))
    {
        Update-GitlabProjectIntegration -ProjectId $Project.Id -Integration 'slack' -Settings $Settings
    }
}
