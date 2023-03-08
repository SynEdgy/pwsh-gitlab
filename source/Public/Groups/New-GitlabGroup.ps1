
# https://docs.gitlab.com/ee/api/groups.html#new-group
function New-GitlabGroup
{
    [CmdletBinding(SupportsShouldProcess)]
    param
    (
        [Parameter(Position = 0, Mandatory = $true)]
        [Alias('Name')]
        [string]
        $GroupName,

        [Parameter()]
        [string]
        $ParentGroupName,

        [Parameter()]
        [ValidateSet('private', 'internal', 'public')]
        [string]
        $Visibility = 'internal',

        [Parameter()]
        [string]
        $SiteUrl
    )

    $Query = @{
        name       = $GroupName
        path       = $GroupName
        visibility = $Visibility
    }

    if ($ParentGroupName)
    {
        $ParentGroup = Get-GitlabGroup -GroupId $ParentGroupName
        $Query.parent_id = $ParentGroup.Id
    }

    if ($PSCmdlet.ShouldProcess($GroupName, "create new $Visibility group '$GroupName'" ))
    {
        Invoke-GitlabApi -HttpMethod 'POST' -Path "groups" -Query $Query -SiteUrl $SiteUrl -WhatIf:$WhatIfPreference |
            New-WrapperObject 'Gitlab.Group'
    }
}
