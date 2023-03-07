
# https://docs.gitlab.com/ee/api/merge_request_approvals.html#create-project-level-rule
function New-GitlabMergeRequestApprovalRule
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        [Parameter(Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]
        $ProjectId = '.',

        [Parameter(Position = 1, Mandatory = $true)]
        [string]
        $Name,

        [Parameter(Position = 2, Mandatory = $true)]
        [uint]
        $ApprovalsRequired,

        [Parameter()]
        [string]
        $SiteUrl
    )

    $Project = Get-GitlabProject $ProjectId

    $Resource = "projects/$($Project.Id)/approval_rules"
    $Rule = @{
        name                              = $Name
        approvals_required                = $ApprovalsRequired
        applies_to_all_protected_branches = 'true'
    }

    if ($PSCmdlet.ShouldProcess($Project.PathWithNamespace, "create new merge request approval rule $($Rule | ConvertTo-Json)"))
    {
        Invoke-GitlabApi POST $Resource -Body $Rule -SiteUrl $SiteUrl | New-WrapperObject 'Gitlab.MergeRequestApprovalRule'
    }
}
