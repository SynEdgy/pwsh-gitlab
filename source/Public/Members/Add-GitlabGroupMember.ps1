
# https://docs.gitlab.com/ee/api/members.html#add-a-member-to-a-group-or-project
function Add-GitlabGroupMember
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        $GroupId,

        [Parameter(Mandatory = $true)]
        [string]
        $UserId,

        [Parameter(Mandatory = $true)]
        [ValidateSet('guest', 'reporter', 'developer', 'maintainer')]
        [string]
        $AccessLevel,

        [Parameter()]
        [string]
        $SiteUrl
    )

    $User = Get-GitlabUser -UserId $UserId -SiteUrl $SiteUrl
    $Group = Get-GitlabGroup -GroupId $GroupId -SiteUrl $SiteUrl -WhatIf:$false

    $Request = @{
        user_id      = $User.Id
        access_level = Get-GitlabMemberAccessLevel $AccessLevel
    }

    if ($PSCmdlet.ShouldProcess($Group.FullName, "grant $($User.Username) '$AccessLevel' membership"))
    {
        Invoke-GitlabApi POST "groups/$($Group.Id)/members" -Body $Request -SiteUrl $SiteUrl |
            New-WrapperObject 'Gitlab.Member'
    }
}
