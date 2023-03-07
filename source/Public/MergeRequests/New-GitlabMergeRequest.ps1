
function New-GitlabMergeRequest
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 0)]
        [string]
        $ProjectId,

        [Parameter(Position = 1)]
        [string]
        $SourceBranch,

        [Parameter(Position = 2)]
        [string]
        $TargetBranch,

        [Parameter(Position = 3)]
        [string]
        $Title,

        [Parameter()]
        [switch]
        $Follow,

        [Parameter()]
        [string]
        $SiteUrl,

        [switch]
        [Parameter()]
        $WhatIf
    )

    if (-not $ProjectId)
    {
        $ProjectId = '.'
    }

    $Project = Get-GitlabProject -ProjectId $ProjectId

    if (-not $TargetBranch)
    {
        $TargetBranch = $Project.DefaultBranch
    }

    if (-not $SourceBranch -or $SourceBranch -eq '.')
    {
        $SourceBranch = $(Get-LocalGitContext).Branch
    }

    if (-not $Title)
    {
        $Title = $SourceBranch.Replace('-', ' ').Replace('_', ' ')
    }

    $Me = Get-GitlabCurrentUser

    $MergeRequest = $(Invoke-GitlabApi POST "projects/$($Project.Id)/merge_requests" @{
            source_branch        = $SourceBranch
            target_branch        = $TargetBranch
            remove_source_branch = 'true'
            assignee_id          = $Me.Id
            title                = $Title
        } -SiteUrl $SiteUrl -WhatIf:$WhatIf) | New-WrapperObject 'Gitlab.MergeRequest'

    if ($Follow)
    {
        Start-Process $MergeRequest.WebUrl
    }

    $MergeRequest
}
