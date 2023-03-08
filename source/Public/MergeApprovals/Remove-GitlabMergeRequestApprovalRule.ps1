
# https://docs.gitlab.com/ee/api/merge_request_approvals.html#delete-project-level-rule
function Remove-GitlabMergeRequestApprovalRule
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        [Parameter(Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]
        $ProjectId = '.',

        [Parameter(Position = 1, Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        $MergeRequestApprovalRuleId,

        [Parameter()]
        [string]
        $SiteUrl
    )

    $Project = Get-GitlabProject $ProjectId

    if ($PSCmdlet.ShouldProcess($Project.PathWithNamespace, "remove merge request approval rule '$MergeRequestApprovalRuleId'"))
    {
        Invoke-GitlabApi -HttpMethod 'DELETE' -Path "projects/$($Project.Id)/approval_rules/$MergeRequestApprovalRuleId" -SiteUrl $SiteUrl
    }
}
