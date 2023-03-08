
function Suspend-GitlabRunner
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

    Update-GitlabRunner $RunnerId -Active $false -SiteUrl $SiteUrl -WhatIf:$WhatIf
}
