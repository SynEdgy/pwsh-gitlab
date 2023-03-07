# https://docs.gitlab.com/ee/api/graphql/
function Invoke-GitlabGraphQL {
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]
        $Query,

        [Parameter()]
        [string]
        $SiteUrl,

        [Parameter()]
        [switch]
        $WhatIf
    )

    $body = @{
        query = $Query
    }

    Invoke-GitlabApi POST 'graphql' -Api '' -Body $body -SiteUrl $SiteUrl -WhatIf:$WhatIf | Select-Object -ExpandProperty data | New-WrapperObject
}
