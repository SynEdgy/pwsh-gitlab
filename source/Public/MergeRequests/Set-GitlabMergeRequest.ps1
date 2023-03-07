
function Set-GitlabMergeRequest
{
    [CmdletBinding()]
    [Alias("mr")]
    param
    (
        #
    )

    $ProjectId = '.'
    $Branch = '.'

    $Existing = Get-GitlabMergeRequest -ProjectId $ProjectId -Branch $Branch -State 'opened'
    if ($Existing)
    {
        return $Existing
    }

    New-GitlabMergeRequest -ProjectId $ProjectId -SourceBranch $Branch
}
