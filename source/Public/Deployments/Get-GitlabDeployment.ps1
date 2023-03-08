
# https://docs.gitlab.com/ee/api/deployments.html#list-project-deployments

function Get-GitlabDeployment
{
    [CmdletBinding(DefaultParameterSetName = "Query")]
    [Alias('deploys')]
    param
    (
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]
        $ProjectId = '.',

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName="Query")]
        [string]
        $EnvironmentName,

        [Parameter(ParameterSetName = "Query")]
        [ValidateSet('created', 'running', 'success', 'failed', 'canceled', 'all')]
        [string]
        $Status = 'success',

        [Parameter(ParameterSetName = "Query")]
        [switch]
        $Latest,

        [Parameter(ParameterSetName = "Query")]
        [string]
        $UpdatedBefore,

        [Parameter(ParameterSetName = "Query")]
        [string]
        $UpdatedAfter,

        [Parameter(ParameterSetName = "Query")]
        [int]
        $MaxPages = 1,

        [Parameter(ParameterSetName = "ById")]
        [Alias("Id")]
        [string]
        $DeploymentId,

        [Parameter()]
        [switch]
        $Pipeline,

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
        SiteUrl = $SiteUrl
    }

    switch ($PSCmdlet.ParameterSetName)
    {
        Query {
            $GitlabApiArguments.Path = "projects/$($Project.Id)/deployments"
            $GitlabApiArguments.Query = @{
                sort='desc'
            }

            $GitlabApiArguments.MaxPages = $MaxPages
            if ($EnvironmentName)
            {
                $GitlabApiArguments.Query['environment'] = $EnvironmentName
            }

            if ($Status -and $Status -ne 'all')
            {
                $GitlabApiArguments.Query['status'] = $Status
            }

            if ($UpdatedBefore)
            {
                $GitlabApiArguments.Query['updated_before'] = $UpdatedBefore
            }

            if ($UpdatedAfter)
            {
                $GitlabApiArguments.Query['updated_after'] = $UpdatedAfter
            }
        }

        ById {
            $GitlabApiArguments.Path = "projects/$($Project.Id)/deployments/$DeploymentId"
        }

        default {
            throw "Parameterset $($PSCmdlet.ParameterSetName) is not implemented"
        }
    }

    $Result = Invoke-GitlabApi @GitlabApiArguments -WhatIf:$WhatIf | New-WrapperObject 'Gitlab.Deployment'

    if ($Latest)
    {
        $Result = $Result | Select-Object -First 1
    }

    if ($Pipeline)
    {
        $Result = $Result.Pipeline
    }

    $Result
}
