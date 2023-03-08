
# https://docs.gitlab.com/ee/api/groups.html#remove-group
function Remove-GitlabGroup
{
    [CmdletBinding(SupportsShouldProcess)]
    param
    (
        [Parameter(Position=0)]
        [string]
        $GroupId,

        [Parameter()]
        [string]
        $SiteUrl
    )

    $Group = Get-GitlabGroup -GroupId $GroupId

    if ($PSCmdlet.ShouldProcess($Group.FullPath, "delete group"))
    {
        $null = Invoke-GitlabApi -HttpMethod 'DELETE' -Path "groups/$($Group.Id)" -SiteUrl $SiteUrl
        # TODO: change this write host to verbose or debug
        Write-Information -InformationAction 'Continue' -MessageData "$($Group.FullPath) deleted"
    }
}
