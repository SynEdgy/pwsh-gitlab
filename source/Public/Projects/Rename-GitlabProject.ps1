
function Rename-GitlabProject
{
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]
        $ProjectId = '.',

        [Parameter(Position = 0, Mandatory = $true)]
        [string]
        $NewName,

        [Parameter()]
        [string]
        $SiteUrl,

        [Parameter()]
        [switch]
        $WhatIf
    )

    Update-GitlabProject -ProjectId $ProjectId -Name $NewName -Path $NewName -SiteUrl $SiteUrl -WhatIf:$WhatIf
}
