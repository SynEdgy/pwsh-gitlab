
function Get-GitlabMergeRequest
{
    [CmdletBinding(DefaultParameterSetName = 'ByProjectId')]
    [Alias('mrs')]
    param
    (
        [Parameter(ParameterSetName = 'ByProjectId', ValueFromPipelineByPropertyName = $true)]
        [string]
        $ProjectId = '.',

        [Parameter(Position = 0, ParameterSetName = 'ByProjectId')]
        [Alias("Id")]
        [string]
        $MergeRequestId,

        [Parameter(Position = 0, Mandatory = $true, ParameterSetName = 'ByGroupId')]
        [string]
        $GroupId,

        [Parameter(Position = 0, Mandatory = $true, ParameterSetName = 'ByUrl')]
        [string]
        $Url,

        [Parameter()]
        [ValidateSet('', 'closed', 'opened', 'merged')]
        [string]
        $State = 'opened',

        [Parameter(ParameterSetName = 'ByGroupId')]
        [Parameter(ParameterSetName = 'ByProjectId')]
        [string]
        $CreatedAfter,

        [Parameter(ParameterSetName = 'ByGroupId')]
        [Parameter(ParameterSetName = 'ByProjectId')]
        [string]
        $CreatedBefore,

        [Parameter(ParameterSetName = 'ByGroupId')]
        [Parameter(ParameterSetName = 'ByProjectId')]
        [ValidateSet($null, $true, $false)]
        [object]
        $IsDraft,

        [Parameter(ParameterSetName = 'ByGroupId')]
        [Parameter(ParameterSetName = 'ByProjectId')]
        [string]
        $Branch,

        [Parameter()]
        [switch]
        $IncludeChangeSummary,

        [Parameter()]
        [switch]
        $IncludeApprovals,

        [Parameter(Mandatory = $true, ParameterSetName='Mine')]
        [switch]
        $Mine,

        [Parameter()]
        [string]
        $SiteUrl,

        [Parameter()]
        [switch]
        $WhatIf
    )

    $Path = $null
    $MaxPages = 1
    $Query = @{}

    if ($Mine)
    {
        $Path = 'merge_requests'
    }
    else
    {
        if ($Url -and $Url -match "$($(Get-DefaultGitlabSite).Url)/(?<ProjectId>.*)/-/merge_requests/(?<MergeRequestId>\d+)")
        {
            $ProjectId = $Matches.ProjectId
            $MergeRequestId = $Matches.MergeRequestId
        }

        if ($ProjectId)
        {
            $ProjectId = $(Get-GitlabProject -ProjectId $ProjectId).Id
        }

        if ($GroupId)
        {
            $GroupId = $(Get-GitlabGroup -GroupId $GroupId).Id
        }

        if ($MergeRequestId)
        {
            # https://docs.gitlab.com/ee/api/merge_requests.html#get-single-mr
            $Path = "projects/$ProjectId/merge_requests/$MergeRequestId"
        }
        elseif ($ProjectId)
        {
            # https://docs.gitlab.com/ee/api/merge_requests.html#list-project-merge-requests
            $Path = "projects/$ProjectId/merge_requests"
            $MaxPages = 10
        }
        elseif ($GroupId)
        {
            # https://docs.gitlab.com/ee/api/merge_requests.html#list-group-merge-requests
            $Path = "groups/$GroupId/merge_requests"
            $MaxPages = 10
        }
        else
        {
            throw "Unsupported parameter combination"
        }
    }

    if ($State)
    {
        $Query['state'] = $State
    }

    if ($CreatedBefore)
    {
        $Query['created_before'] = $CreatedBefore
    }

    if ($CreatedAfter)
    {
        $Query['created_after'] = $CreatedAfter
    }

    if ($IsDraft)
    {
        $Query['wip'] = $IsDraft ? 'yes' : 'no'
    }

    if ($Branch)
    {
        if ($Branch -eq '.')
        {
            $Branch = Get-LocalGitContext | Select-Object -ExpandProperty Branch
        }

        $Query['source_branch'] = $Branch
    }

    $MergeRequests = Invoke-GitlabApi -HttpMethod 'GET' -Path $Path -Query $Query -MaxPages $MaxPages -SiteUrl $SiteUrl -WhatIf:$WhatIf | New-WrapperObject 'Gitlab.MergeRequest'

    if ($IncludeChangeSummary)
    {
        $MergeRequests | ForEach-Object {
            $_ | Add-Member -MemberType 'NoteProperty' -Name 'ChangeSummary' -Value $($_ | Get-GitlabMergeRequestChangeSummary)
        }
    }

    if ($IncludeApprovals)
    {
        $MergeRequests | ForEach-Object {
            $_ | Add-GitlabMergeRequestApprovals
        }
    }

    $MergeRequests | Sort-Object ProjectPath
}
