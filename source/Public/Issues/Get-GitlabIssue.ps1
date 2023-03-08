function Get-GitlabIssue
{
    [CmdletBinding(DefaultParameterSetName='ByProjectId')]
    [Alias('issue')]
    [Alias('issues')]
    param
    (
        [Parameter(ParameterSetName = 'ByProjectId', ValueFromPipelineByPropertyName = $true)]
        [string]
        $ProjectId = '.',

        [Parameter(Position = 0, ParameterSetName = 'ByProjectId')]
        [string]
        $IssueId,

        [Parameter(Position = 0, Mandatory = $true, ParameterSetName = 'ByGroupId', ValueFromPipelineByPropertyName = $true)]
        [string]
        $GroupId,

        [Parameter(ParameterSetName='ByGroupId')]
        [Parameter(ParameterSetName='ByProjectId')]
        [Parameter(ParameterSetName='Mine')]
        [ValidateSet($null, 'opened', 'closed')]
        [string]
        $State = 'opened',

        [Parameter(ParameterSetName='ByGroupId')]
        [Parameter(ParameterSetName='ByProjectId')]
        [Parameter(ParameterSetName='Mine')]
        [string]
        $CreatedAfter,

        [Parameter(ParameterSetName='ByGroupId')]
        [Parameter(ParameterSetName='ByProjectId')]
        [Parameter(ParameterSetName='Mine')]
        [string]
        $CreatedBefore,

        [Parameter(Mandatory = $true, ParameterSetName = 'Mine')]
        [switch]
        $Mine,

        [Parameter()]
        [uint]
        $MaxPages = 1,

        [Parameter()]
        [string]
        $SiteUrl,

        [Parameter()]
        [switch]
        $WhatIf
    )

    $Path = $null
    $Query = @{}

    if ($Mine)
    {
        $Path = 'issues'
    }
    else
    {
        if ($ProjectId)
        {
            $ProjectId = $(Get-GitlabProject -ProjectId $ProjectId).Id
        }

        if ($GroupId)
        {
            $GroupId = $(Get-GitlabGroup -GroupId $GroupId).Id
        }

        if ($IssueId)
        {
            $Path = "projects/$ProjectId/issues/$IssueId"
        }
        elseif ($GroupId)
        {
            $Path = "groups/$GroupId/issues"
            $MaxPages = 10
        }
        else
        {
            $Path = "projects/$ProjectId/issues"
            $MaxPages = 10
        }
    }

    if ($Visibility)
    {
        $Query.visibility = $State
    }

    if ($State)
    {
        $Query.state = $State
    }

    if ($CreatedBefore)
    {
        $Query.created_before = $CreatedBefore
    }

    if ($CreatedAfter)
    {
        $Query.created_after = $CreatedAfter
    }

    Invoke-GitlabApi -HttpMethod 'GET' -Path $Path -Query $Query -MaxPages $MaxPages -SiteUrl $SiteUrl -WhatIf:$WhatIf |
        New-WrapperObject 'Gitlab.Issue' |
        Sort-Object SortKey
}
