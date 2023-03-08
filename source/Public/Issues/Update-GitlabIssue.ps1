
# https://docs.gitlab.com/ee/api/issues.html#edit-issue
function Update-GitlabIssue
{
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]
        $ProjectId = '.',

        [Parameter(Position = 0, Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        $IssueId,

        [Parameter()]
        [string []]
        $AssigneeId,

        [Parameter()]
        [switch]
        $Confidential,

        [Parameter()]
        [string]
        $Description,

        [Parameter()]
        [switch]
        $DiscussionLocked,

        [Parameter()]
        [ValidateScript({ValidateGitlabDateFormat $_})]
        [string]
        $DueDate,

        [Parameter()]
        [ValidateSet('issue', 'incident', 'test_case')]
        [string]
        $IssueType,

        [Parameter()]
        [string []]
        $Label,

        [Parameter()]
        [switch]
        $LabelBehaviorAdd,

        [Parameter()]
        [switch]
        $LabelBehaviorRemove,

        [Parameter()]
        [string]
        $MilestoneId,

        [Parameter()]
        [string]
        [ValidateSet('close', 'reopen')]
        $StateEvent,

        [Parameter()]
        [string]
        $Title,

        [Parameter()]
        [nullable[uint]]
        $Weight,

        [Parameter()]
        [string]
        $SiteUrl,

        [Parameter()]
        [switch]
        $WhatIf
    )

    $Body = @{}

    if ($AssigneeId)
    {
        if ($AssigneeId -is [array])
        {
            $Body.assignee_ids = $AssigneeId -join ','
        }
        else
        {
            $Body.assignee_id = $AssigneeId
        }
    }

    if ($Confidential.IsPresent)
    {
        $Body.confidential = $Confidential.ToBool().ToString().ToLower()
    }

    if ($Description)
    {
        $Body.description = $Description
    }

    if ($DiscussionLocked.IsPresent)
    {
        $Body.discussion_locked = $DiscussionLocked.ToBool().ToString().ToLower()
    }

    if ($DueDate)
    {
        $Body.due_date = $DueDate
    }

    if ($IssueType)
    {
        $Body.issue_type = $IssueType
    }

    if ($Label)
    {
        $Labels = $Label -join ','
        if ($LabelBehaviorAdd)
        {
            $Body.add_labels = $Labels
        }
        elseif ($LabelBehaviorRemove)
        {
            $Body.remove_labels = $Labels
        }
        else
        {
            $Body.labels = $Labels
        }
    }

    if ($MilestoneId)
    {
        $Body.milestone_id = $MilestoneId
    }

    if ($StateEvent)
    {
        $Body.state_event = $StateEvent
    }

    if ($Title)
    {
        $Body.title = $Title
    }

    if ($Weight.HasValue)
    {
        $Body.weight = $Weight.Value
    }

    $ProjectId = $(Get-GitlabProject -ProjectId $ProjectId).Id

    return Invoke-GitlabApi -HttpMethod 'PUT' -Path "projects/$ProjectId/issues/$IssueId" -Body $Body -SiteUrl $SiteUrl -WhatIf:$WhatIf |
        New-WrapperObject 'Gitlab.Issue'
}
