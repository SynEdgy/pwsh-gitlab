
# https://docs.gitlab.com/ee/api/topics.html#list-topics

function Get-GitlabTopic
{
    [CmdletBinding(DefaultParameterSetName = 'Search')]
    param
    (
        [Parameter(Mandatory = $true, ParameterSetName = 'Id')]
        [Alias('Id')]
        [string]
        $TopicId,

        [Parameter(ParameterSetName = 'Search', Position = 0)]
        [string]
        $Search,

        [Parameter(ParameterSetName = 'Search')]
        [switch]
        $WithoutProjects,

        [Parameter(ParameterSetName = 'Search')]
        [uint]
        $MaxPages,

        [Parameter(ParameterSetName = 'Search')]
        [switch]
        $All,

        [Parameter()]
        [string]
        $SiteUrl
    )

    if ($All)
    {
        if ($MaxPages)
        {
            Write-Warning -Message "Ignoring -MaxPages in favor of -All"
        }

        $MaxPages = [uint]::MaxValue
    }

    $Query = @{}
    switch ($PSCmdlet.ParameterSetName)
    {
        Search  { $Url = 'topics'  }
        Id      { $Url = "topics/$TopicId" }
        default { throw "$($PSCmdlet.ParameterSetName) is not supported"}
    }

    if ($Search)
    {
        $Query.search = $Search
    }

    if ($WithoutProjects)
    {
        $Query.without_projects = 'true'
    }

    Invoke-GitlabApi -HttpMethod 'GET' -Path $Url -Query $Query -MaxPages $MaxPages -SiteUrl $SiteUrl |
        New-WrapperObject 'Gitlab.Topic' |
        Sort-Object Name
}
