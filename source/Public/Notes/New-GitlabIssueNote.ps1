
# https://docs.gitlab.com/ee/api/notes.html#create-new-issue-note
function New-GitlabIssueNote
{
    param
    (
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]
        $ProjectId = '.',

        [Parameter(Position = 0, Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        $IssueId,

        [Parameter(Position = 1, Mandatory = $true)]
        [string]
        $Note,

        [Parameter()]
        [string]
        $SiteUrl,

        [Parameter()]
        [switch]
        $WhatIf
    )

    $Project = Get-GitlabProject $ProjectId
    $body = @{
        body = $Note
    }

    Invoke-GitlabApi -HttpMethod 'POST' -Path "projects/$($Project.Id)/issues/$IssueId/notes" -Body $body -SiteUrl $SiteUrl -WhatIf:$WhatIf | New-WrapperObject 'Gitlab.Note'
}
