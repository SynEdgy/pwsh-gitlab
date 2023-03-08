
# https://docs.gitlab.com/ee/api/integrations.html#list-all-active-integrations

function Get-GitlabProjectIntegration
{
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]
        $ProjectId = '.',

        [Parameter(Position = 0)]
        [ValidateSet($null, 'assana', 'assembla', 'bamboo', 'bugzilla', 'buildkite', 'campfire', 'datadog', 'unify-circuit', 'pumble', 'webex-teams', 'custom-issue-tracker', 'discord', 'drone-ci', 'emails-on-push', 'ewm', 'confluence', 'external-wiki', 'flowdock', 'github', 'hangouts-chat', 'irker', 'jira', 'slack-slash-commands', 'mattermost-slash-commands', 'packagist', 'pipelines-email', 'pivotaltracker', 'prometheus', 'pushover', 'redmine', 'slack', 'microsoft-teams', 'mattermost', 'teamcity', 'jenkins', 'jenkins-deprecated', 'mock-ci', 'youtrack')]
        [string]
        $Integration,

        [Parameter()]
        [string]
        $SiteUrl
    )

    $Project = Get-GitlabProject $ProjectId -SiteUrl $SiteUrl

    $Resource = "projects/$($Project.Id)/integrations"
    if ($Integration)
    {
        $Resource += "/$Integration"
    }

    Invoke-GitlabApi -HttpMethod 'GET' -Path $Resource -SiteUrl $SiteUrl | New-WrapperObject 'Gitlab.ProjectIntegration'
}
