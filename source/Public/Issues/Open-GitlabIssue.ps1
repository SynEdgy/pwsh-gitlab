
function Open-GitlabIssue
{
    [Alias('Reopen-GitlabIssue')]
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

        [switch]
        [Parameter()]
        $WhatIf
    )

    Update-GitlabIssue -ProjectId $ProjectId $IssueId -StateEvent 'reopen' -SiteUrl $SiteUrl -WhatIf:$WhatIf
}
