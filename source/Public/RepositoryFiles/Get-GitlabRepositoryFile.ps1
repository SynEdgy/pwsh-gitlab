
function Get-GitlabRepositoryFile
{
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]
        $ProjectId = '.',

        [Parameter(Position = 0, Mandatory = $true)]
        [string]
        $FilePath,

        [Parameter()]
        [Alias("Branch")]
        [string]
        $Ref,

        [Parameter()]
        [string]
        $SiteUrl
    )


    if ($FilePath.StartsWith('./'))
    {
        $FilePath = $FilePath.Substring(2);
    }

    $Project = Get-GitlabProject $ProjectId

    if (-not $Ref)
    {
        $Ref = $Project.DefaultBranch
    }

    $RefName = $(Get-GitlabBranch -ProjectId $ProjectId -Ref $Ref).Name

    return Invoke-GitlabApi -HttpMethod 'GET' -Path "projects/$($Project.Id)/repository/files/$($FilePath | ConvertTo-UrlEncoded)?ref=$RefName" -SiteUrl $SiteUrl |
        New-WrapperObject 'Gitlab.RepositoryFile'
}
