
# https://docs.gitlab.com/ee/api/members.html#add-a-member-to-a-group-or-project
function Add-GitlabUserMembership
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        $Username,

        [Parameter(Position = 1, Mandatory = $true)]
        [string]
        $GroupId,

        [Parameter(Position = 2, Mandatory = $true)]
        [ValidateSet('developer', 'maintainer', 'owner')]
        [string]
        $AccessLevel,

        [Parameter()]
        [string]
        $SiteUrl,

        [Parameter()]
        [switch]
        $WhatIf
    )

    $Group = Get-GitlabGroup -GroupId $GroupId
    $User = Get-GitlabUser -UserId $Username

    $null = Invoke-GitlabApi -HttpMethod 'POST' -Path "groups/$($Group.Id)/members" @{
        user_id = $User.Id
        access_level = Get-GitlabMemberAccessLevel $AccessLevel
    }  -SiteUrl $SiteUrl -WhatIf:$WhatIf

    #TODO: Replace this write host with verbose or debug
    Write-Information -InformationAction 'Continue' -MessageData "$($User.Username) added to $($Group.FullPath)"
}
