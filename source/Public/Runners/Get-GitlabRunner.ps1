function Get-GitlabRunner
{
    [CmdletBinding(DefaultParameterSetName = 'ListAll')]
    param
    (
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'RunnerId')]
        [string]
        $RunnerId,

        [Parameter(ParameterSetName = 'ListAll')]
        [ValidateSet('instance_type', 'group_type', 'project_type')]
        [string]
        $Type,

        [Parameter(ParameterSetName = 'ListAll')]
        [ValidateSet('active', 'paused', 'online', 'offline')]
        [string]
        $Status,

        [Parameter(ParameterSetName='ListAll')]
        [string []]
        $Tags,

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

    $Params = @{
        HttpMethod = 'GET'
        Query      = @{}
        MaxPages   = $MaxPages
        SiteUrl    = $SiteUrl
        WhatIf     = $WhatIf
    }

    switch ($PSCmdlet.ParameterSetName)
    {
        # https://docs.gitlab.com/ee/api/runners.html#get-runners-details
        RunnerId {
            $Params.Path = "runners/$RunnerId"
        }

        # https://docs.gitlab.com/ee/api/runners.html#list-all-runners
        ListAll {
            $Params.Path = 'runners/all'
            $Params.Query.type = $Type
            $Params.Query.status = $Status
            $Params.Query.tag_list = $Tags -join ','
        }

        default {
            throw "Unsupported parameter combination"
        }
    }

    Invoke-GitlabApi @Params | New-WrapperObject 'Gitlab.Runner'
}
