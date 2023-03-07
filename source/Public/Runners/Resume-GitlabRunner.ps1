
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

        [switch]
        [Parameter()]
        $WhatIf
    )

    Update-GitlabRunner $RunnerId -Active $true -SiteUrl $SiteUrl -WhatIf:$WhatIf
}
