
function Resume-GitlabRunner
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]
        $RunnerId,

        [Parameter()]
        [string]
        $SiteUrl,

        [Parameter()]
        [switch]
        $WhatIf
    )

    Update-GitlabRunner $RunnerId -Active $true -SiteUrl $SiteUrl -WhatIf:$WhatIf
}
