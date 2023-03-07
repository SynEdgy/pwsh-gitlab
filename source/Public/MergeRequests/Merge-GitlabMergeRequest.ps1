
function Merge-GitlabMergeRequest
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]
        $ProjectId,

        [Parameter(Position = 1, Mandatory = $true)]
        [string]
        $MergeRequestId,

        [Parameter()]
        [string]
        $MergeCommitMessage,

        [Parameter()]
        [string]
        $SquashCommitMessage,

        [Parameter()]
        [bool]
        $Squash = $false,

        [Parameter()]
        [bool]
        $ShouldRemoveSourceBranch = $true,

        [Parameter()]
        [bool]
        $MergeWhenPipelineSucceeds = $false,

        [Parameter()]
        [string]
        $Sha,

        [Parameter()]
        [string]
        $SiteUrl,

        [switch]
        [Parameter()]
        $WhatIf
    )

    $Project = Get-GitlabProject -ProjectId $ProjectId

    $MergeRequest = $(Invoke-GitlabApi PUT "projects/$($Project.Id)/merge_requests/$MergeRequestId/merge" @{
            merge_commit_message         = $MergeCommitMessage
            squash_commit_message        = $SquashCommitMessage
            squash                       = $Squash
            should_remove_source_branch  = $ShouldRemoveSourceBranch
            merge_when_pipeline_succeeds = $MergeWhenPipelineSucceeds
            sha                          = $Sha
        } -SiteUrl $SiteUrl -WhatIf:$WhatIf) | New-WrapperObject 'Gitlab.MergeRequest'

    $MergeRequest
}
