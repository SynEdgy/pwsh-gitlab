
# https://docs.gitlab.com/ee/api/issues.html#new-issue
function New-GitlabIssue
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [string]
        $ProjectId = '.',

        [Parameter(Position = 0, Mandatory = $true)]
        [string]
        $Title,

        [Parameter(Position=1)]
        [string]
        $Description,

        [Parameter()]
        [string]
        $SiteUrl,

        [Parameter()]
        [switch]
        $WhatIf
    )

    $ProjectId = $(Get-GitlabProject -ProjectId $ProjectId).Id

    Invoke-GitlabApi -HttpMethod 'POST' -Path "projects/$ProjectId/issues" -Body @{
        title       = $Title
        description = $Description
        assignee_id = $(Get-GitlabUser -Me).Id
    } -SiteUrl $SiteUrl -WhatIf:$WhatIf |
        New-WrapperObject 'Gitlab.Issue'
}
