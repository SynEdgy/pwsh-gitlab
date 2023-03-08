# https://docs.gitlab.com/ee/api/pipelines.html#list-project-pipelines
function Get-GitlabPipeline
{
    [Alias('pipeline')]
    [Alias('pipelines')]
    [CmdletBinding(DefaultParameterSetName="ByProjectId")]
    param
    (
        [Parameter(ParameterSetName = "ByProjectId", ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = "ByPipelineId")]
        [string]
        $ProjectId=".",

        [Parameter(ParameterSetName = "ByProjectId")]
        [Alias("Branch")]
        [string]
        $Ref,

        [Parameter(ParameterSetName = "ByPipelineId", Position = 0)]
        [string]
        $PipelineId,

        [Parameter(ParameterSetName = "ByProjectId")]
        [ValidateSet('running', 'pending', 'finished', 'branches', 'tags')]
        [string]
        $Scope,

        [Parameter(ParameterSetName = "ByProjectId")]
        [ValidateSet('created', 'waiting_for_resource', 'preparing', 'pending', 'running', 'success', 'failed', 'canceled', 'skipped', 'manual', 'scheduled')]
        [string]
        $Status,

        [Parameter(ParameterSetName = "ByProjectId")]
        [ValidateSet('push', 'web', 'trigger', 'schedule', 'api', 'external', 'pipeline', 'chat', 'webide', 'merge_request_event', 'external_pull_request_event', 'parent_pipeline', 'ondemand_dast_scan', 'ondemand_dast_validation')]
        [string]
        $Source,

        [Parameter(ParameterSetName = "ByProjectId")]
        [string]
        $Username,

        [Parameter(ParameterSetName = "ByProjectId")]
        [switch]
        $Mine,

        [Parameter(ParameterSetName = "ByProjectId")]
        [switch]
        $Latest,

        [Parameter()]
        [switch]
        $IncludeTestReport,

        [Parameter()]
        [Alias('FetchUpstream')]
        [switch]
        $FetchDownstream,

        [Parameter(ParameterSetName = "ByProjectId")]
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

    $GitlabApiParameters = @{
        HttpMethod = "GET"
        Path       = "projects/$($Project.Id)/pipelines"
        SiteUrl    = $SiteUrl
    }

    switch ($PSCmdlet.ParameterSetName)
    {
        ByPipelineId {
            $GitlabApiParameters["Path"] += "/$PipelineId"
        }

        ByProjectId {
            $Query = @{}

            if ($Ref)
            {
                if ($Ref -eq '.')
                {
                    $LocalContext = Get-LocalGitContext
                    $Ref = $LocalContext.Branch
                }

                $Query['ref'] = $Ref
            }

            if ($Scope)
            {
                $Query['scope'] = $Scope
            }

            if ($Status)
            {
                $Query['status'] = $Status
            }

            if ($Source)
            {
                $Query['source'] = $Source
            }

            if ($Mine)
            {
                $Query['username'] = $(Get-GitlabUser -Me).Username
            }
            elseif ($Username)
            {
                $Query['username'] = $Username
            }

            $GitlabApiParameters["Query"] = $Query
            $GitlabApiParameters["MaxPages"] = $MaxPages
        }

        default {
            throw "Parameterset $($PSCmdlet.ParameterSetName) is not implemented"
        }
    }

    if ($WhatIf)
    {
        $GitlabApiParameters["WhatIf"] = $True
    }

    $Pipelines = Invoke-GitlabApi @GitlabApiParameters -WhatIf:$WhatIf | New-WrapperObject 'Gitlab.Pipeline'

    if ($IncludeTestReport)
    {
        $Pipelines | ForEach-Object {
            try
            {
                $TestReport = Invoke-GitlabApi -HttpMethod 'GET' -Path "projects/$($_.ProjectId)/pipelines/$($_.Id)/test_report" -SiteUrl $SiteUrl -WhatIf:$WhatIf | New-WrapperObject 'Gitlab.TestReport'
            }
            catch
            {
                $TestReport = $Null
            }

            $_ | Add-Member -MemberType 'NoteProperty' -Name 'TestReport' -Value $TestReport
        }
    }

    if ($Latest)
    {
        $Pipelines = $Pipelines | Sort-Object -Descending Id | Select-Object -First 1
    }

    if ($FetchDownstream)
    {
        # the API doesn't currently expose this, so working around using GraphQL
        # https://gitlab.com/gitlab-org/gitlab/-/issues/21495
        foreach ($Pipeline in $Pipelines)
        {
            # NOTE: have to stitch this together because of https://gitlab.com/gitlab-org/gitlab/-/issues/350686
            $Bridges = Get-GitlabPipelineBridge -ProjectId $Project.Id  -PipelineId $Pipeline.Id -SiteUrl $SiteUrl -WhatIf:$WhatIf

            # NOTE: once 14.6 is more available, iid is included in pipeline APIs which would make this simpler (not have to search by sha)
            $Query = @"
            { project(fullPath: "$($Project.PathWithNamespace)") { id pipelines (sha: "$($Pipeline.Sha)") { nodes { id downstream { nodes { id project { fullPath } } } upstream { id project { fullPath } } } } } }
"@
            $Nodes = $(Invoke-GitlabGraphQL -Query $Query -SiteUrl $SiteUrl -WhatIf:$WhatIf).Project.pipelines.nodes
            $MatchingResult = $Nodes | Where-Object id -Match "gid://gitlab/Ci::Pipeline/$($Pipeline.Id)"
            if ($MatchingResult.downstream)
            {
                $DownstreamList = $MatchingResult.downstream.nodes | ForEach-Object {
                    if ($_.id -match "/(?<PipelineId>\d+)")
                    {
                        try
                        {
                            Get-GitlabPipeline -ProjectId $_.project.fullPath -PipelineId $Matches.PipelineId -SiteUrl $SiteUrl -WhatIf:$WhatIf
                        }
                        catch
                        {
                            $Null
                        }
                    }
                } | Where-Object { $_ }

                $DownstreamMap = @{}

                foreach ($Downstream in $DownstreamList)
                {
                    $MatchingBridge = $Bridges | Where-Object { $_.DownstreamPipeline.id -eq $Downstream.Id }
                    $DownstreamMap[$MatchingBridge.Name] = $Downstream
                }

                $Pipeline | Add-Member -MemberType 'NoteProperty' -Name 'Downstream' -Value $DownstreamMap
            }

            if ($MatchingResult.upstream.id -match '\/(?<PipelineId>\d+)')
            {
                try
                {
                    $Upstream = Get-GitlabPipeline -ProjectId $MatchingResult.upstream.project.fullPath -PipelineId $Matches.PipelineId -SiteUrl $SiteUrl -WhatIf:$WhatIf
                    $Pipeline | Add-Member -MemberType 'NoteProperty' -Name 'Upstream' -Value $Upstream
                }
                catch
                {
                    Write-Debug -Message ('Exception caught: {0}' -f $_)
                }
            }
        }
    }

    $Pipelines
}
