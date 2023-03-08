

# https://docs.gitlab.com/ee/api/groups.html#update-group
function Update-GitlabGroup
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]
        $GroupId,

        [Parameter()]
        [string]
        $Name,

        [Parameter()]
        [string]
        $Path,

        [Parameter()]
        [ValidateSet('private', 'internal', 'public')]
        [string]
        $Visibility,

        [Parameter()]
        [string]
        $SiteUrl,

        [Parameter()]
        [switch]
        $WhatIf
    )

    $GroupId = $GroupId | ConvertTo-UrlEncoded

    $Body = @{}

    if ($Name)
    {
        $Body.name = $Name
    }

    if ($Path)
    {
        $Body.path = $Path
    }

    if ($Visibility)
    {
        $Body.visibility = $Visibility
    }

    Invoke-GitlabApi -HttpMethod 'PUT' -Path "groups/$GroupId" -Body $Body -SiteUrl $SiteUrl -WhatIf:$WhatIf | New-WrapperObject 'Gitlab.Group'
}
