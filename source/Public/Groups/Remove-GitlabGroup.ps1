
# https://docs.gitlab.com/ee/api/groups.html#remove-group
function Remove-GitlabGroup
{
    [CmdletBinding(SupportsShouldProcess)]
    param
    (
        [Parameter(Position=0, Mandatory=$false)]
        [string]
        $GroupId,

        [Parameter(Mandatory=$false)]
        [string]
        $SiteUrl
    )

    $Group = Get-GitlabGroup -GroupId $GroupId

    if ($PSCmdlet.ShouldProcess($Group.FullPath, "delete group"))
    {
        $null = Invoke-GitlabApi DELETE "groups/$($Group.Id)" -SiteUrl $SiteUrl
        # TODO: change this write host to verbose or debug
        Write-Host -Object "$($Group.FullPath) deleted"
    }
}
