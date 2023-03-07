
# https://docs.gitlab.com/ee/api/protected_branches.html#list-protected-branches

function New-GitlabBranch
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 0)]
        [string]
        $ProjectId = '.',

        [Parameter(Position = 1, Mandatory = $true)]
        [string]
        $Branch,

        [Parameter(Position = 2, Mandatory = $true)]
        [string]
        $Ref,

        [switch]
        [Parameter()]
        $WhatIf
    )

    $ProjectId = $(Get-GitlabProject -ProjectId $ProjectId).Id

    Invoke-GitlabApi POST "projects/$ProjectId/repository/branches" @{
        branch = $Branch
        ref = $Ref
    } -SiteUrl $SiteUrl -WhatIf:$WhatIf | New-WrapperObject 'Gitlab.Branch'
}
