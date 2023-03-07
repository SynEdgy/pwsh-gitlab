
# https://docs.gitlab.com/ee/api/groups.html#details-of-a-group
function Get-GitlabGroup
{
    [CmdletBinding(DefaultParameterSetName='ByGroupId')]
    param
    (
        [Parameter(Position = 0, ParameterSetName = 'ByGroupId')]
        [string]
        $GroupId,

        [Parameter(Mandatory = $true, ParameterSetName = 'ByParentGroup')]
        [string]
        $ParentGroupId,

        [Parameter(ParameterSetName = 'ByParentGroup')]
        [Alias('r')]
        [switch]
        $Recurse,

        [Parameter()]
        [string]
        $SiteUrl,

        [Parameter()]
        [switch]
        $WhatIf
    )

    $MaxPages = 10
    if($GroupId)
    {
        if ($GroupId -eq '.')
        {
            $LocalPath = Get-Location | Select-Object -ExpandProperty Path
            $MaxDepth = 3
            for ($i = 1; $i -le $MaxDepth; $i++)
            {
                $PossibleGroupName = Get-PossibleGroupName $LocalPath $i
                try
                {
                    $Group = Get-GitlabGroup $PossibleGroupName -SiteUrl $SiteUrl -WhatIf:$false
                    if ($Group)
                    {
                        return $Group
                    }
                }
                catch
                {
                    #TODO: Log some info in debug stream?
                }

                Write-Verbose "Didn't find a group named '$PossibleGroupName'"
            }
        }
        else
        {
            # https://docs.gitlab.com/ee/api/groups.html#details-of-a-group
            $Group = Invoke-GitlabApi GET "groups/$($GroupId | ConvertTo-UrlEncoded)" @{
                'with_projects' = 'false'
            } -SiteUrl $SiteUrl -WhatIf:$WhatIf
        }
    }
    elseif ($ParentGroupId)
    {
        #TODO: This is only PS7+ compatible, any reason?
        $SubgroupOperation = $Recurse ?
            'descendant_groups' # https://docs.gitlab.com/ee/api/groups.html#list-a-groups-descendant-groups
            :
            'subgroups' # https://docs.gitlab.com/ee/api/groups.html#list-a-groups-subgroups
        $Group = Invoke-GitlabApi GET "groups/$($ParentGroupId | ConvertTo-UrlEncoded)/$SubgroupOperation" `
          -SiteUrl $SiteUrl -WhatIf:$WhatIf -MaxPages $MaxPages
    }
    else
    {
        # https://docs.gitlab.com/ee/api/groups.html#list-groups
        $Group = Invoke-GitlabApi GET "groups" @{
            'top_level_only' = (-not $Recurse).ToString().ToLower()
        } -MaxPages $MaxPages -SiteUrl $SiteUrl -WhatIf:$WhatIf
    }

    return $Group |
        Where-Object -Not marked_for_deletion_on |
        New-WrapperObject 'Gitlab.Group'
}
