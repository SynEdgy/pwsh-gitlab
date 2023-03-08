
# https://docs.gitlab.com/ee/api/users.html#user-memberships-admin-only
function Get-GitlabUserMembership
{
    [CmdletBinding(DefaultParameterSetName = 'ByUsername')]
    param
    (
        [Parameter(ParameterSetName = 'ByUsername', Position = 0, Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        $Username,

        [Parameter(ParameterSetName = 'Me')]
        [switch]
        $Me,

        [Parameter()]
        [string]
        $SiteUrl,

        [Parameter()]
        [switch]
        $WhatIf
    )

    if ($Me)
    {
        $Username = $(Get-GitlabUser -Me).Username
    }

    $User = Get-GitlabUser -Username $Username -SiteUrl $SiteUrl

    Invoke-GitlabApi -HttpMethod 'GET' -Path "users/$($User.Id)/memberships" -MaxPages 10 -SiteUrl $SiteUrl -WhatIf:$WhatIf |
        New-WrapperObject 'Gitlab.UserMembership'
}
