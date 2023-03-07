
function Get-GitlabRepositoryTree
{
    param
    (
        [Parameter()]
        [string]
        $ProjectId = '.',

        [Parameter(Position = 0)]
        [string]
        $Path,

        [Parameter()]
        [Alias("Branch")]
        [string]
        $Ref,

        [Parameter()]
        [Alias('r')]
        [switch]
        $Recurse,

        [Parameter()]
        [string]
        $SiteUrl,

        [switch]
        [Parameter()]
        $WhatIf
    )

    $Project = Get-GitlabProject $ProjectId
    if (-not $Ref)
    {
        $Ref = $Project.DefaultBranch
    }

    $RefName = $(Get-GitlabBranch -ProjectId $ProjectId -Ref $Ref).Name

    Invoke-GitlabApi GET "projects/$($Project.Id)/repository/tree?ref=$RefName&path=$Path&recursive=$($Recurse.ToString().ToLower())" -MaxPages 10 -SiteUrl $SiteUrl -WhatIf:$WhatIf |
        New-WrapperObject 'Gitlab.RepositoryTree'
}
