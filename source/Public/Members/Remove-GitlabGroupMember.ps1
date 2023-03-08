
# https://docs.gitlab.com/ee/api/members.html#remove-a-member-from-a-group-or-project
function Remove-GitlabGroupMember
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $GroupId,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('Username')]
        [string]
        $UserId,

        [Parameter()]
        [string]
        $SiteUrl
    )

    $User = Get-GitlabUser -UserId $UserId -SiteUrl $SiteUrl
    $Group = Get-GitlabGroup -GroupId $GroupId -SiteUrl $SiteUrl

    if ($PSCmdlet.ShouldProcess($Group.FullName, "remove $($User.Username)'s group membership"))
    {
        try
        {
            $null = Invoke-GitlabApi -HttpMethod 'DELETE' -Path "groups/$($Group.Id)/members/$($User.Id)" -SiteUrl $SiteUrl -WhatIf:$WhatIf
            Write-Information -InformationAction 'Continue' -MessageData "Removed $($User.Username) from $($Group.Name)"
        }
        catch
        {
            Write-Error -Message "Error removing $($User.Username) from $($Group.Name): $_"
        }
    }
}
