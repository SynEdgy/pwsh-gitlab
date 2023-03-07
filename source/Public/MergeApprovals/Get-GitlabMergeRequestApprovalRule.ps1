
# https://docs.gitlab.com/ee/api/merge_request_approvals.html#get-project-level-rules
# https://docs.gitlab.com/ee/api/merge_request_approvals.html#get-a-single-project-level-rule
function Get-GitlabMergeRequestApprovalRule
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]
        $ProjectId = '.',

        [Parameter(Position = 1, ValueFromPipelineByPropertyName = $true)]
        [string]
        $ApprovalRuleId,

        [Parameter()]
        [string]
        $SiteUrl
    )

    $Project = Get-GitlabProject $ProjectId

    $Resource = "projects/$($Project.Id)/approval_rules"
    if ($ApprovalRuleId)
    {
        $Resource += "/$ApprovalRuleId"
    }

    Invoke-GitlabApi GET $Resource -SiteUrl $SiteUrl
        | New-WrapperObject 'Gitlab.MergeRequestApprovalRule'
        | Add-Member -MemberType 'NoteProperty' -Name 'ProjectId' -Value $Project.Id -PassThru
}
