
function Remove-GitlabBranch
{
    [CmdletBinding(DefaultParameterSetName = 'ByName')]
    param
    (
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [string]
        $ProjectId = '.',

        [Parameter(Position = 0, Mandatory = $true, ParameterSetName = 'ByName', ValueFromPipelineByPropertyName = $true)]
        [string]
        $Name,

        [switch]
        [Parameter(Mandatory = $false, ParameterSetName = 'MergedBranches')]
        $MergedBranches,

        [Parameter(Mandatory=$false)]
        [string]
        $SiteUrl,

        [switch]
        [Parameter(Mandatory=$false)]
        $WhatIf
    )

    $Project = Get-GitlabProject $ProjectId

    switch ($PSCmdlet.ParameterSetName)
    {
        ByName {
            # https://docs.gitlab.com/ee/api/branches.html#delete-repository-branch
            Invoke-GitlabApi DELETE "projects/$($Project.Id)/repository/branches/$Name" -SiteUrl $SiteUrl -WhatIf:$WhatIf
        }

        MergedBranches {
            # https://docs.gitlab.com/ee/api/branches.html#delete-merged-branches
            Invoke-GitlabApi DELETE "projects/$($Project.Id)/repository/merged_branches" -SiteUrl $SiteUrl -WhatIf:$WhatIf
        }

        Default {
            throw "Unsupported parameter set $($PSCmdlet.ParameterSetName)"
        }
    }
}
