
# https://docs.gitlab.com/ee/api/projects.html#transfer-a-project-to-a-new-namespace
function Move-GitlabProject
{
    [Alias("Transfer-GitlabProject")]
    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]
        $ProjectId = '.',

        [Parameter(Mandatory = $true)]
        [string]
        $DestinationGroup,

        [Parameter()]
        [string]
        $SiteUrl
    )

    $SourceProject = Get-GitlabProject -ProjectId $ProjectId
    $Group = Get-GitlabGroup -GroupId $DestinationGroup

    if ($PSCmdlet.ShouldProcess($Group.FullName, "transfer '$($SourceProject.PathWithNamespace)'"))
    {
        Invoke-GitlabApi -HttpMethod 'PUT' -Path "projects/$($SourceProject.Id)/transfer" @{
            namespace = $Group.Id
        } -SiteUrl $SiteUrl -WhatIf:$WhatIfPreference | New-WrapperObject 'Gitlab.Project'
    }
}
