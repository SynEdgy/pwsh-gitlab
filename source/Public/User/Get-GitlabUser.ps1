function Get-GitlabUser
{
    [CmdletBinding(DefaultParameterSetName = 'ByUserId')]
    param
    (
        [Parameter(Position = 0, ParameterSetName = 'ByUserId', ValueFromPipelineByPropertyName = $true)]
        [Alias("Username")]
        [string]
        $UserId,

        [Parameter(ParameterSetName = 'ByEmail')]
        [string]
        $EmailAddress,

        [Parameter(ParameterSetName = 'ByMe')]
        [switch]
        $Me,

        [Parameter()]
        [string]
        $SiteUrl
    )

    #TODO: do a switch case ParameterSetName instead of if/if/if
    if ($UserId)
    {
        if (-not [uint]::TryParse($UserId, [ref] $null))
        {
            $ErrorMessage = "$UserId not found" # pre-compute as we re-assign below
            $UserId = Invoke-GitlabApi GET "users" @{
                username = $UserId
            } | Select-Object -First 1 -ExpandProperty id

            if (-not $UserId)
            {
                throw $ErrorMessage
            }
        }

        Invoke-GitlabApi GET "users/$UserId" -SiteUrl $SiteUrl | New-WrapperObject 'Gitlab.User'
    }

    if ($EmailAddress)
    {
        $UserId = Invoke-GitlabApi GET "search" @{
            scope  = 'users'
            search = $EmailAddress
        } -SiteUrl $SiteUrl | Select-Object -First 1 -ExpandProperty id

        if (-not $WhatIf -and -not $UserId)
        {
            throw "No user found for $EmailAddress"
        }

        Invoke-GitlabApi GET "users/$UserId" -SiteUrl $SiteUrl | New-WrapperObject 'Gitlab.User'
    }

    if ($Me)
    {
        Invoke-GitlabApi GET 'user' -SiteUrl $SiteUrl | New-WrapperObject 'Gitlab.User'
    }
}
