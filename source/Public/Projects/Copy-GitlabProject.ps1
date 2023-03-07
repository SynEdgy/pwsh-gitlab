

# https://docs.gitlab.com/ee/api/projects.html#fork-project
function Copy-GitlabProject
{
    [Alias("Fork-GitlabProject")]
    [CmdletBinding(SupportsShouldProcess)]
    param
    (
        [Parameter()]
        [string]
        $ProjectId = '.',

        [Parameter(Position = 0, Mandatory = $true)]
        [string]
        $DestinationGroup,

        [Parameter()]
        [string]
        $DestinationProjectName,

        [Parameter()]
        [bool]
        # https://docs.gitlab.com/ee/api/projects.html#delete-an-existing-forked-from-relationship
        $PreserveForkRelationship = $true,

        [Parameter()]
        [string]
        $SiteUrl
    )

    $SourceProject = Get-GitlabProject -ProjectId $ProjectId
    $Group = Get-GitlabGroup -GroupId $DestinationGroup

    if ($PSCmdlet.ShouldProcess("$($Group.FullPath)", "$($PreserveForkRelationship ? "fork" : "copy") $($SourceProject.Path)"))
    {
        $NewProject = Invoke-GitlabApi POST "projects/$($SourceProject.Id)/fork" @{
            namespace_id           = $Group.Id
            name                   = $DestinationProjectName ?? $SourceProject.Name
            path                   = $DestinationProjectName ?? $SourceProject.Name
            mr_default_target_self = 'true'
        } -SiteUrl $SiteUrl -WhatIf:$WhatIfPreference

        if (-not $PreserveForkRelationship)
        {
            Invoke-GitlabApi DELETE "projects/$($NewProject.id)/fork" -SiteUrl $SiteUrl -WhatIf:$WhatIfPreference | Out-Null
            Write-Host "Removed fork relationship between $($SourceProject.Name) and $($NewProject.PathWithNamespace)"
        }
    }
}
