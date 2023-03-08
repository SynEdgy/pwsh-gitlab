function Search-Gitlab
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [ValidateSet('blobs', 'merge_requests', 'projects')]
        [string]
        $Scope = 'blobs',

        [Parameter(Position = 0, Mandatory = $true)]
        [string]
        $Search,

        [Parameter()]
        [uint]
        $MaxResults = $GitlabSearchResultsDefaultLimit,

        [Parameter()]
        [switch]
        $All,

        [Parameter()]
        [string]
        $Select,

        [Parameter()]
        [switch]
        $OpenInBrowser,

        [Parameter()]
        [string]
        $SiteUrl,

        [Parameter()]
        [switch]
        $WhatIf
    )

    if ($All)
    {
        if ($MaxResults -ne $GitlabSearchResultsDefaultLimit)
        {
            Write-Warning -Message "Ignoring -MaxResults in favor of -All"
        }

        $MaxResults = [uint]::MaxValue
    }

    $PageSize = 20
    $MaxPages = [Math]::Max(1, $MaxResults / $PageSize)
    $Query = @{
        scope    = $Scope
        per_page = $PageSize
        search   = $Search
    }

    switch ($Scope)
    {
        blobs {
            $DisplayType = 'Gitlab.SearchResult.Blob'
        }

        merge_requests {
            $DisplayType = 'Gitlab.SearchResult.MergeRequest'
        }

        projects {
            $DisplayType = 'Gitlab.SearchResult.Project'
        }
    }

    $Results = Invoke-GitlabApi -HttpMethod 'GET' -Path 'search' -Query $Query -MaxPages $MaxPages -SiteUrl $SiteUrl -WhatIf:$WhatIf | New-WrapperObject $DisplayType

    if ($Scope -eq 'blobs')
    {
        # the response object is too anemic to be useful.  enrich with project data
        $Projects = $Results.ProjectId | Select-Object -Unique | ForEach-Object {
            @{
                Id = $_
                Project = Get-GitlabProject $_
            }
        }

        $Results | ForEach-Object {
            $_ | Add-Member -MemberType 'NoteProperty' -Name 'Project' -Value $($Projects | Where-Object Id -eq $_.ProjectId | Select-Object -ExpandProperty Project)
        }
    }

    if ($OpenInBrowser)
    {
        $Results | Where-Object Url | ForEach-Object {
            $_ | Open-InBrowser
        }
    }

    $Results | Get-FilteredObject $Select | Sort-Object ProjectPath
}
