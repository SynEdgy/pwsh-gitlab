
function Rename-GitlabGroup
{
    param
    (
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]
        $GroupId = '.',

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

    Update-GitlabGroup $GroupId -Name $NewName -Path $NewName -SiteUrl $SiteUrl -WhatIf:$WhatIf
}
