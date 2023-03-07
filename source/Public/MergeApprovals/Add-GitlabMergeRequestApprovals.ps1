
function Add-GitlabMergeRequestApprovals
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        $MergeRequest
    )

    $Path = "projects/$($MergeRequest.SourceProjectId)/merge_requests/$($MergeRequest.MergeRequestId)/approvals"
    $approvalDetails = Invoke-GitlabApi GET $Path

    $MergeRequest | Add-Member -MemberType NoteProperty -Name ApprovalsRequired -Value $approvalDetails.approvals_required -Force
    $MergeRequest | Add-Member -MemberType NoteProperty -Name ApprovalsLeft -Value $approvalDetails.approvals_left -Force
    $MergeRequest | Add-Member -MemberType NoteProperty -Name ApprovedBy -Value $approvalDetails.approved_by.user.name
    #TODO: passthru? Chain with passThru?
}
