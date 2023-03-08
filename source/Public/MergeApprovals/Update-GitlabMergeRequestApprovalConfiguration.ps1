# https://docs.gitlab.com/ee/api/merge_request_approvals.html#change-configuration
function Update-GitlabMergeRequestApprovalConfiguration
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', Scope='Function',Justification = 'RequirePasswordToApprove not a password. Ignoring PSSA warning.')]
    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        [Parameter(Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]
        $ProjectId = '.',

        [Parameter()]
        [ValidateSet($null, 'true', 'false')]
        [object]
        $DisableOverridingApproversPerMergeRequest,

        [Parameter()]
        [ValidateSet($null, 'true', 'false')]
        [object]
        $MergeRequestsAuthorApproval,

        [Parameter()]
        [ValidateSet($null, 'true', 'false')]
        [object]
        $MergeRequestsDisableCommittersApproval,

        [Parameter()]
        [ValidateSet($null, 'true', 'false')]
        [object]
        $RequirePasswordToApprove,

        [Parameter()]
        [ValidateSet($null, 'true', 'false')]
        [object]
        $ResetApprovalsOnPush,

        [Parameter()]
        [ValidateSet($null, $true, $false)]
        [object]
        $SelectiveCodeOwnerRemovals,

        [Parameter()]
        [string]
        $SiteUrl
    )

    $Project = Get-GitlabProject $ProjectId
    $Request = @{}

    if ($null -ne $DisableOverridingApproversPerMergeRequest)
    {
        $Request.disable_overriding_approvers_per_merge_request = $DisableOverridingApproversPerMergeRequest.ToLower()
    }

    if ($null -ne $MergeRequestsAuthorApproval)
    {
        $Request.merge_requests_author_approval = $MergeRequestsAuthorApproval.ToLower()
    }

    if ($null -ne $MergeRequestsDisableCommittersApproval)
    {
        $Request.merge_requests_disable_committers_approval = $MergeRequestsDisableCommittersApproval.ToLower()
    }

    if ($null -ne $RequirePasswordToApprove)
    {
        $Request.require_password_to_approve = $RequirePasswordToApprove.ToLower()
    }

    if ($null -ne $ResetApprovalsOnPush)
    {
        $Request.reset_approvals_on_push = $ResetApprovalsOnPush.ToLower()
    }

    if ($null -ne $SelectiveCodeOwnerRemovals)
    {
        $Request.selective_code_owner_removals = $SelectiveCodeOwnerRemovals.ToLower()
    }

    if ($PSCmdlet.ShouldProcess($Project.PathWithNamespace, "update merge request approval settings to $($Request | ConvertTo-Json)"))
    {
        Invoke-GitlabApi -HttpMethod 'POST' -Path "projects/$($Project.Id)/approvals" -Body $Request -SiteUrl $SiteUrl | New-WrapperObject
    }
}
