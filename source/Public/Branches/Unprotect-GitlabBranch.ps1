
# https://docs.gitlab.com/ee/api/protected_branches.html#unprotect-repository-branches

function UnProtect-GitlabBranch
{
    [CmdletBinding(SupportsShouldProcess)]
    param
    (
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]
        $ProjectId = '.',

        [Parameter(Position = 0, Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('Branch')]
        [string]
        $Name,

        [Parameter()]
        [string]
        $SiteUrl
    )

    $Project = Get-GitlabProject -ProjectId $ProjectId

    if ($PSCmdlet.ShouldProcess("$($Project.PathWithNamespace)/branches/$($Name)", "unprotect branch $($Name)"))
    {
        Invoke-GitlabApi -HttpMethod 'DELETE' -Path "projects/$($Project.Id)/protected_branches/$($Name)" -SiteUrl $SiteUrl
    }
}
