

# https://docs.gitlab.com/ee/api/notes.html#list-all-merge-request-notes
function Get-GitlabMergeRequestNote
{
    param
    (
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]
        $ProjectId = '.',

        [Parameter(Position = 0, Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        $MergeRequestId,

        [Parameter(Position = 1)]
        [string]
        $NoteId,

        [Parameter()]
        [string]
        $SiteUrl,

        [switch]
        [Parameter()]
        $WhatIf
    )

    $Project = Get-GitlabProject $ProjectId

    $Url = "projects/$($Project.Id)/merge_requests/$MergeRequestId/notes"

    if ($NoteId)
    {
        $Url += "/$NoteId"
    }

    Invoke-GitlabApi GET $Url -SiteUrl $SiteUrl -WhatIf:$WhatIf | New-WrapperObject 'Gitlab.Note'
}
