
# https://docs.gitlab.com/ee/api/commits.html#list-repository-commits

function Get-GitlabCommit
{
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]
        $ProjectId = '.',

        [Parameter()]
        [Alias('Until')]
        [ValidateScript({ValidateGitlabDateFormat $_})]
        [string]
        $Before,

        [Parameter()]
        [Alias('Since')]
        [ValidateScript({ValidateGitlabDateFormat $_})]
        [string]
        $After,

        [Parameter()]
        [Alias('Branch')]
        [string]
        $Ref,

        [Parameter()]
        [string]
        $Sha,

        [Parameter()]
        [uint]
        $MaxPages = 1,

        [Parameter()]
        [string]
        $SiteUrl
    )

    $Project = Get-GitlabProject $ProjectId

    $Url = "projects/$($Project.Id)/repository/commits"
    $Query = @{}

    if ($Before)
    {
        $Query.until = $Before
    }

    if ($After)
    {
        $Query.since = $After
    }

    if ($Ref)
    {
        $Query.ref_name = $Ref
    }

    if ($Sha)
    {
        $Url += "/$Sha"
    }

    Invoke-GitlabApi -HttpMethod 'GET' -Path $Url -Query $Query -MaxPages $MaxPages -SiteUrl $SiteUrl | New-WrapperObject 'Gitlab.Commit'
}
