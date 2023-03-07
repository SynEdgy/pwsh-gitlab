
function Get-GitlabVersion
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [string]
        $Select = 'Version',

        [Parameter()]
        [string]
        $SiteUrl,

        [switch]
        [Parameter()]
        $WhatIf
    )

    Invoke-GitlabApi GET 'version' -SiteUrl $SiteUrl -WhatIf:$WhatIf | New-WrapperObject | Get-FilteredObject $Select
}
