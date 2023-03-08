
# https://docs.gitlab.com/ee/api/protected_branches.html#list-protected-branches

function Get-GitlabBranch
{
    [CmdletBinding(DefaultParameterSetName="ByProjectId")]
    param
    (
        [Parameter(ParameterSetName = "ByProjectId", ValueFromPipelineByPropertyName)]
        [Parameter(ParameterSetName = "ByRef",  ValueFromPipelineByPropertyName)]
        [string]
        $ProjectId = '.',

        [Parameter(ParameterSetName = "ByProjectId")]
        [string]
        $Search,

        [Parameter(ParameterSetName = "ByRef", Mandatory = $true)]
        [Alias("Branch")]
        [string]
        $Ref,

        [Parameter()]
        [string]
        $SiteUrl,

        [Parameter()]
        [switch]
        $WhatIf
    )

    $Project = Get-GitlabProject -ProjectId $ProjectId

    if ($Ref -eq '.')
    {
        $Ref = $(Get-LocalGitContext).Branch
    }

    $GitlabApiArguments = @{
        HttpMethod = 'GET'
        Path       = "projects/$($Project.Id)/repository/branches"
        Query      = @{}
        SiteUrl    = $SiteUrl
    }

    switch ($PSCmdlet.ParameterSetName)
    {
        ByProjectId {
            if ($Search)
            {
                $GitlabApiArguments.Query["search"] = $Search
            }
        }

        ByRef {
            $GitlabApiArguments.Path += "/$($Ref)"
        }

        default {
            throw "Parameterset $($PSCmdlet.ParameterSetName) is not implemented"
        }
    }

    Invoke-GitlabApi @GitlabApiArguments -WhatIf:$WhatIf
        | New-WrapperObject 'Gitlab.Branch'
        | Add-Member -MemberType 'NoteProperty' -Name 'ProjectId' -Value $Project.Id -PassThru
        | Sort-Object -Descending LastUpdated
}
