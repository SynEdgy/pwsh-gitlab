

function Get-GitlabEnvironment
{
    [CmdletBinding(DefaultParameterSetName='List')]
    [Alias('envs')]
    param
    (
        [Parameter()]
        [string]
        $ProjectId = '.',

        [Parameter(ParameterSetName = 'Name', Mandatory = $true)]
        [string]
        $Name,

        [Parameter(ParameterSetName='Search', Mandatory = $true)]
        [string]
        $Search,

        [Parameter()]
        [switch]
        $IncludeStopped,

        [Parameter()]
        [int]
        $MaxPages = 1,

        [Parameter()]
        [string]
        $SiteUrl,

        [Parameter()]
        [switch]
        $WhatIf
    )

    $Project = Get-GitlabProject -ProjectId $ProjectId

    $GitlabApiArguments = @{
        HttpMethod = 'GET'
        Path       = "projects/$($Project.Id)/environments"
        Query      = @{}
        SiteUrl    = $SiteUrl
        MaxPages   = $MaxPages
    }

    switch ($PSCmdlet.ParameterSetName)
    {
        Name {
            $GitlabApiArguments.Query['name'] = $Name
        }

        Search {
            $GitlabApiArguments.Query['search'] = $Search
        }
    }

    if ((-not $IncludeStopped) -and (-not $Name))
    {
        $GitlabApiArguments.Query['states'] = 'available'
    }

    Invoke-GitlabApi @GitlabApiArguments -WhatIf:$WhatIf | New-WrapperObject 'Gitlab.Environment'
}
