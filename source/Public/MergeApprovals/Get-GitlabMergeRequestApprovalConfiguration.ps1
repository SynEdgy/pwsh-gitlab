
# https://docs.gitlab.com/ee/api/merge_request_approvals.html#get-configuration
function Get-GitlabMergeRequestApprovalConfiguration
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]
        $ProjectId = '.',

        [Parameter()]
        [string]
        $SiteUrl
    )

    $Project = Get-GitlabProject $ProjectId

    Invoke-GitlabApi GET "projects/$($Project.Id)/approvals" -SiteUrl $SiteUrl | New-WrapperObject
}
