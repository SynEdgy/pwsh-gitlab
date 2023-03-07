
function Get-GitlabProjectEvent
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 0)]
        [string]
        $ProjectId = '.',

        [Parameter()]
        [ValidateScript({ValidateGitlabDateFormat $_})]
        [string]
        $Before,

        [Parameter()]
        [ValidateScript({ValidateGitlabDateFormat $_})]
        [string]
        $After,

        [Parameter()]
        [ValidateSet("asc","desc")]
        [string]
        $Sort,

        [Parameter()]
        [int]
        $MaxPages = 1,

        [Parameter()]
        [string]
        $SiteUrl,

        [switch]
        [Parameter()]
        $WhatIf
    )

    $Project = Get-GitLabProject $ProjectId

    $Query = @{}
    if($Before)
    {
        $Query.before = $Before
    }

    if($After)
    {
        $Query.after = $After
    }

    if($Sort)
    {
        $Query.sort = $Sort
    }

    Invoke-GitlabApi GET "projects/$($Project.Id)/events" `
        -Query $Query -MaxPages $MaxPages -SiteUrl $SiteUrl -WhatIf:$WhatIf |
        New-WrapperObject 'Gitlab.Event'
}
