
function Close-GitlabIssue
{
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]
        $ProjectId = '.',

        [Parameter(Position = 0, Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        $IssueId,

        [Parameter()]
        [string]
        $SiteUrl,

        [Parameter()]
        [switch]
        $WhatIf
    )

    Update-GitlabIssue -ProjectId $ProjectId $IssueId -StateEvent 'close' -SiteUrl $SiteUrl -WhatIf:$WhatIf
}
