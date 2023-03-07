
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

        [Parameter(Mandatory = $false)]
        [string]
        $SiteUrl,

        [switch]
        [Parameter(Mandatory = $false)]
        $WhatIf
    )

    $Project = Get-GitlabProject $ProjectId

    Invoke-GitlabApi POST "projects/$($Project.Id)/issues/$IssueId/notes" -Body @{body = $Note} -SiteUrl $SiteUrl -WhatIf:$WhatIf | New-WrapperObject 'Gitlab.Note'
}
