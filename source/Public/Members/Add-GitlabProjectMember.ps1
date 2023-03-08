
# https://docs.gitlab.com/ee/api/members.html#add-a-member-to-a-group-or-project
function Add-GitlabProjectMember
{
    param
    (
        [Parameter()]
        [string]
        $ProjectId = '.',

        [Parameter(Position = 0, Mandatory = $true)]
        [Alias('Username')]
        [string]
        $UserId,

        [Parameter(Position = 1, Mandatory = $true)]
        [ValidateSet('guest', 'reporter', 'developer', 'maintainer')]
        [string]
        $AccessLevel,

        [Parameter()]
        [string]
        $SiteUrl,

        [Parameter()]
        [switch]
        $WhatIf
    )

    $User = Get-GitlabUser -UserId $UserId -SiteUrl $SiteUrl
    $Project = Get-GitlabProject -ProjectId $ProjectId -SiteUrl $SiteUrl -WhatIf:$false

    $Query = @{
        user_id      = $User.Id
        access_level = Get-GitlabMemberAccessLevel $AccessLevel
    }

    Invoke-GitlabApi -HttpMethod 'POST' -Path "projects/$($Project.Id)/members" -Query $Query -SiteUrl $SiteUrl -WhatIf:$WhatIf |
        New-WrapperObject 'Gitlab.Member'
}
