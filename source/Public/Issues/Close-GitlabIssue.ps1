
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

        [Parameter(Mandatory = $false)]
        [string]
        $SiteUrl,

        [switch]
        [Parameter(Mandatory = $false)]
        $WhatIf
    )

    Update-GitlabIssue -ProjectId $ProjectId $IssueId -StateEvent 'close' -SiteUrl $SiteUrl -WhatIf:$WhatIf
}
