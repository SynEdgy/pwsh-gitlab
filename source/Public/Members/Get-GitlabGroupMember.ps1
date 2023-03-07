
# https://docs.gitlab.com/ee/api/members.html#list-all-members-of-a-group-or-project
function Get-GitlabGroupMember
{
    param
    (
        [Parameter(Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]
        $GroupId = '.',

        [Parameter()]
        [string]
        $UserId,

        [switch]
        [Parameter()]
        $All,

        [Parameter()]
        [ValidateSet('guest', 'reporter', 'developer', 'maintainer', 'owner')]
        [string]
        $MinAccessLevel,

        [Parameter()]
        [int]
        $MaxPages = 10,

        [Parameter()]
        [string]
        $SiteUrl,

        [Parameter()]
        [switch]
        $WhatIf
    )

    $Group = Get-GitlabGroup -GroupId $GroupId -SiteUrl $SiteUrl -WhatIf:$false

    if ($UserId)
    {
        $User = Get-GitlabUser -UserId $UserId -SiteUrl $SiteUrl
    }

    $Members = $All ? "members/all" : "members"
    $Resource = $User ? "groups/$($Group.Id)/$Members/$($User.Id)" : "groups/$($Group.Id)/$Members"

    $Members = Invoke-GitlabApi GET $Resource -MaxPages $MaxPages -SiteUrl $SiteUrl -WhatIf:$WhatIf
    if ($MinAccessLevel)
    {
        $MinAccessLevelLiteral = Get-GitlabMemberAccessLevel $MinAccessLevel
        $Members = $Members | Where-Object access_level -ge $MinAccessLevelLiteral
    }

    $Members | New-WrapperObject 'Gitlab.Member'
}
