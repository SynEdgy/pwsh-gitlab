
# https://docs.gitlab.com/ee/api/projects.html#edit-project

function Update-GitlabProject
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]
        $ProjectId = '.',

        [Parameter()]
        [ValidateSet('private', 'internal', 'public')]
        [string]
        $Visibility,

        [Parameter()]
        [string]
        $Name,

        [Parameter()]
        [string]
        $Path,

        [Parameter()]
        [string]
        $DefaultBranch,

        [Parameter()]
        [string []]
        $Topics,

        [Parameter()]
        [ValidateSet('fetch', 'clone')]
        [string]
        $BuildGitStrategy,

        [Parameter()]
        [uint]
        $CiDefaultGitDepth,

        [Parameter()]
        [ValidateSet($null, 'true', 'false')]
        [object]
        $CiForwardDeployment,

        [Parameter()]
        [ValidateSet('disabled', 'private', 'enabled')]
        [string]
        $RepositoryAccessLevel,

        [Parameter()]
        [ValidateSet('disabled', 'private', 'enabled')]
        [string]
        $BuildsAccessLevel,

        [Parameter()]
        [string]
        $SiteUrl
    )

    $Project = Get-GitlabProject $ProjectId

    $Query = @{}

    if ($CiForwardDeployment)
    {
        $Query.ci_forward_deployment_enabled = $CiForwardDeployment
    }

    if ($BuildGitStrategy)
    {
        $Query.build_git_strategy = $BuildGitStrategy
    }

    if ($CiDefaultGitDepth)
    {
        $Query.ci_default_git_depth = $CiDefaultGitDepth
    }

    if ($Visibility)
    {
        $Query.visibility = $Visibility
    }

    if ($Name)
    {
        $Query.name = $Name
    }

    if ($Path)
    {
        $Query.path = $Path
    }

    if ($DefaultBranch)
    {
        $Query.default_branch = $DefaultBranch
    }

    if ($Topics)
    {
        $Query.topics = $Topics -join ','
    }

    if ($RepositoryAccessLevel)
    {
        $Query.repository_access_level = $RepositoryAccessLevel
    }

    if ($BuildsAccessLevel)
    {
        $Query.builds_access_level = $BuildsAccessLevel
    }

    if ($PSCmdlet.ShouldProcess("$($Project.PathWithNamespace)", "update project ($($Query | ConvertTo-Json))"))
    {
        Invoke-GitlabApi -HttpMethod 'PUT' -Path "projects/$($Project.Id)" -Query $Query -SiteUrl $SiteUrl |
            New-WrapperObject 'Gitlab.Project'
    }
}
