
# https://docs.gitlab.com/ee/api/search.html#project-search-api
function Search-GitlabProject
{
    param
    (
        [Parameter()]
        [string]
        $ProjectId = '.',

        [Parameter()]
        [string]
        $Search,

        [Parameter()]
        [string]
        $Filename,

        [Parameter()]
        [string]
        $SiteUrl,

        [switch]
        [Parameter()]
        $WhatIf
    )

    $Query = @{
        scope = 'blobs'
    }

    $Project = Get-GitlabProject $ProjectId

    if ($Filename)
    {
        $Query.search = "filename:$Filename"
    }
    else
    {
        $Query.search = $Search
    }

    $Resource = "projects/$($ProjectId | ConvertTo-UrlEncoded)/search"
    Invoke-GitlabApi GET $Resource $Query -SiteUrl $SiteUrl -WhatIf:$WhatIf |
        New-WrapperObject 'Gitlab.SearchResult.Blob' |
        Add-Member -MemberType 'NoteProperty' -Name 'Project' -Value $Project -PassThru
}
