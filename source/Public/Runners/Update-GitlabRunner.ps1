
# https://docs.gitlab.com/ee/api/runners.html#update-runners-details
function Update-GitlabRunner
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]
        $RunnerId,

        [Parameter()]
        [string]
        $Id,

        [Parameter()]
        [string]
        $Description,

        [Parameter()]
        [ValidateSet($null, $true, $false)]
        [object]
        $Active,

        [Parameter()]
        [string]
        $Tags,

        [Parameter()]
        [ValidateSet($null, $true, $false)]
        [object]
        $RunUntaggedJobs,

        [Parameter()]
        [ValidateSet($null, $true, $false)]
        [object]
        $Locked,

        [Parameter()]
        [ValidateSet('not_protected', 'ref_protected')]
        [string]
        $AccessLevel,

        [Parameter()]
        [uint]
        $MaximumTimeoutSeconds,

        [Parameter()]
        [string]
        $SiteUrl,

        [Parameter()]
        [switch]
        $WhatIf
    )

    $Params = @{
        HttpMethod = 'PUT'
        Path       = "runners/$RunnerId"
        Query      = @{
            id           = $Id
            description  = $Description
            tag_list     = $Tags
            access_level = $AccessLevel
        }
        SiteUrl    = $SiteUrl
        WhatIf     = $WhatIf
    }

    if ($MaximumTimeoutSeconds)
    {
        if ($MaximumTimeoutSeconds -lt 600)
        {
            throw "maximum_timeout must be >= 600"
        }

        if ($MaximumTimeoutSeconds -gt [int]::MaxValue)
        {
            throw "maximum_timeout must be <= $([int]::MaxValue)"
        }

        $Params.Query.maximum_timeout = $MaximumTimeoutSeconds
    }

    if ($null -ne $Active)
    {
        $Params.Query.active = $Active.ToString().ToLower()
    }

    if ($null -ne $RunUntaggedJobs)
    {
        $Params.Query.run_untagged = $RunUntaggedJobs.ToString().ToLower()
    }

    if ($null -ne $Locked)
    {
        $Params.Query.locked = $Locked.ToString().ToLower()
    }

    Invoke-GitlabApi @Params | New-WrapperObject 'Gitlab.Runner'
}
