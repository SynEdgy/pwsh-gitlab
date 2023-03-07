<#
.SYNOPSIS
Get one or more Gitlab projects

.DESCRIPTION
Lookup metadata about Gitlab projects by one or more identifiers

.PARAMETER ProjectId
Project id - can be an integer, or a full path

.PARAMETER GroupId
Group id - can be an integer, or a full path

.PARAMETER Recurse
Whether or not to recurse specified group (default: false)
Alias: -r

.PARAMETER Url
Get a project by URL

.PARAMETER IncludeArchived
Whether or not to return archived projects (default: false)

.PARAMETER MaxPages
Maximum pages to return (default: 10)

.PARAMETER SiteUrl
Which Gitlab instance to query.  This is optional, if not provided, will
first attempt to use the remote associated with the local git context.
If there is no established context (or no matching configuration), the default
site is used.

.PARAMETER WhatIf
Preview Gitlab API requests

.EXAMPLE
Get-GitlabProject

Get a project from local git context

.EXAMPLE
Get-GitlabProject -ProjectId 'mygroup/myproject'
OR
PS > Get-GitlabProject 'mygroup/myproject'
OR
PS > Get-GitlabProject 42

Get a single project by id

.EXAMPLE
Get-GitlabProject -GroupId 'mygroup' [-Recurse]

Get multiple projects by containing group

.EXAMPLE
Get-GitlabGroup 'mygroup' | Get-GitlabProject

Enumerate projects within a group

.LINK
https://github.com/chris-peterson/pwsh-gitlab#projects

.LINK
https://docs.gitlab.com/ee/api/projects.html
#>
function Get-GitlabProject
{
    [CmdletBinding(DefaultParameterSetName = 'ById')]
    param
    (
        [Parameter(Position = 0, ParameterSetName = 'ById', ValueFromPipelineByPropertyName = $true)]
        [string]
        $ProjectId = '.',

        [Parameter(Position = 0, Mandatory = $true, ParameterSetName = 'ByGroup', ValueFromPipelineByPropertyName = $true)]
        [string]
        $GroupId,

        [Parameter(ParameterSetName = 'ByUser')]
        [string]
        $UserId,

        [Parameter(ParameterSetName = 'ByUser')]
        [switch]
        $Mine,

        [Parameter(Position = 0, Mandatory = $true, ParameterSetName = 'ByTopics')]
        [string []]
        $Topics,

        [Parameter(ParameterSetName = 'ByGroup')]
        [Alias('r')]
        [switch]
        $Recurse,

        [Parameter(Position = 0, Mandatory = $true, ParameterSetName = 'ByUrl')]
        [string]
        $Url,

        [Parameter()]
        [string]
        $Select,

        [switch]
        [Parameter(ParameterSetName = 'ByGroup')]
        $IncludeArchived = $false,

        [switch]
        [Parameter()]
        $All,

        [Parameter()]
        [uint]
        $MaxPages = $GitlabGetProjectDefaultPages,

        [Parameter()]
        [string]
        $SiteUrl,

        [switch]
        [Parameter()]
        $WhatIf
    )

    if ($All)
    {
        if ($MaxPages -ne $GitlabGetProjectDefaultPages)
        {
            Write-Warning -Message "Ignoring -MaxPages in favor of -All"
        }

        $MaxPages = [uint]::MaxValue
    }

    $Projects = @()
    switch ($PSCmdlet.ParameterSetName)
    {
        ById {
            if ($ProjectId -eq '.')
            {
                $ProjectId = $(Get-LocalGitContext).Project
                if (-not $ProjectId)
                {
                    throw "Could not infer project based on current directory ($(Get-Location))"
                }
            }

            $Projects = Invoke-GitlabApi GET "projects/$($ProjectId | ConvertTo-UrlEncoded)" -SiteUrl $SiteUrl -WhatIf:$WhatIf
        }

        ByGroup {
            $Group = Get-GitlabGroup $GroupId
            $Query = @{
                'include_subgroups' = $Recurse ? 'true' : 'false'
            }

            if (-not $IncludeArchived)
            {
                $Query['archived'] = 'false'
            }

            $Projects = Invoke-GitlabApi GET "groups/$($Group.Id)/projects" $Query -MaxPages $MaxPages -SiteUrl $SiteUrl -WhatIf:$WhatIf |
                Where-Object { $($_.path_with_namespace).StartsWith($Group.FullPath) } |
                Sort-Object -Property 'Name'
        }

        ByUser {
            # https://docs.gitlab.com/ee/api/projects.html#list-user-projects
            if ($Mine)
            {
                if ($UserId)
                {
                    Write-Warning "Ignoring '-UserId $UserId' parameter since -Mine was also provided"
                }

                $UserId = Get-GitlabUser -Me | Select-Object -ExpandProperty Username
            }

            $Projects = Invoke-GitlabApi GET "users/$UserId/projects"
        }

        ByTopics {
            $Projects = Invoke-GitlabApi GET "projects" -Query @{
                topic = $Topics -join ','
            } -MaxPages $MaxPages -SiteUrl $SiteUrl -WhatIf:$WhatIf
        }

        ByUrl {
            $null = $Url -match "$($(Get-DefaultGitlabSite).Url)/(?<ProjectId>.*)"

            if ($Matches)
            {
                $ProjectId = $Matches.ProjectId
                $ProjectId = $Matches.ProjectId
                Get-GitlabProject -ProjectId $ProjectId
            }
            else
            {
                throw "Url didn't match expected format"
            }
        }
    }

    $Projects |
        New-WrapperObject 'Gitlab.Project' |
        Get-FilteredObject $Select
}
