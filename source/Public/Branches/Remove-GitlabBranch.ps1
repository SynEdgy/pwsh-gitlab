
function Remove-GitlabBranch
{
    [CmdletBinding(DefaultParameterSetName = 'ByName')]
    param
    (
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]
        $ProjectId = '.',

        [Parameter(Position = 0, Mandatory = $true, ParameterSetName = 'ByName', ValueFromPipelineByPropertyName = $true)]
        [string]
        $Name,

        [Parameter(ParameterSetName = 'MergedBranches')]
        [switch]
        $MergedBranches,

        [Parameter()]
        [string]
        $SiteUrl,

        [Parameter()]
        [switch]
        $WhatIf
    )

    $Project = Get-GitlabProject $ProjectId

    switch ($PSCmdlet.ParameterSetName)
    {
        ByName {
            # https://docs.gitlab.com/ee/api/branches.html#delete-repository-branch
            Invoke-GitlabApi -HttpMethod 'DELETE' -Path "projects/$($Project.Id)/repository/branches/$Name" -SiteUrl $SiteUrl -WhatIf:$WhatIf
        }

        MergedBranches {
            # https://docs.gitlab.com/ee/api/branches.html#delete-merged-branches
            Invoke-GitlabApi -HttpMethod 'DELETE' -Path "projects/$($Project.Id)/repository/merged_branches" -SiteUrl $SiteUrl -WhatIf:$WhatIf
        }

        default {
            throw "Unsupported parameter set $($PSCmdlet.ParameterSetName)"
        }
    }
}
