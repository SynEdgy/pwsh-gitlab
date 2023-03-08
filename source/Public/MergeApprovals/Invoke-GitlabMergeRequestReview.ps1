
function Invoke-GitlabMergeRequestReview
{
    [CmdletBinding()]
    [Alias('Review-GitlabMergeRequest')]
    param
    (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]
        $MergeRequestId,

        [Parameter()]
        [string]
        $SiteUrl,

        [Parameter()]
        [switch]
        $WhatIf
    )

    $ProjectId = $(Get-GitlabProject -ProjectId '.').Id

    $MergeRequest = Get-GitlabMergeRequest -ProjectId $ProjectId -MergeRequestId $MergeRequestId

    $null = git stash
    $null = git pull -p
    git checkout $MergeRequest.SourceBranch
    git diff "origin/$($MergeRequest.TargetBranch)"
}
