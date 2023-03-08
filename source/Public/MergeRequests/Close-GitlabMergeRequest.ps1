
function Close-GitlabMergeRequest
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        $ProjectId,

        [Parameter(Position = 1, Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('Id')]
        [string]
        $MergeRequestId,

        [Parameter()]
        [switch]
        $WhatIf
    )

    $ProjectId = $(Get-GitlabProject -ProjectId $ProjectId).Id

    Update-GitlabMergeRequest -ProjectId $ProjectId -MergeRequestId $MergeRequestId -Close -WhatIf:$WhatIf
}
