
# https://docs.gitlab.com/ee/api/members.html#remove-a-member-from-a-group-or-project
function Remove-GitlabProjectMember
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]
        $ProjectId = '.',

        [Parameter(Position = 0, Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('Username')]
        [string]
        $UserId,

        [Parameter()]
        [string]
        $SiteUrl
    )

    $User = Get-GitlabUser -UserId $UserId -SiteUrl $SiteUrl
    $Project = Get-GitlabProject -ProjectId $ProjectId -SiteUrl $SiteUrl

    if ($PSCmdlet.ShouldProcess("$($Project.PathWithNamespace)", "Remove $($User.Username)'s membership"))
    {
        try
        {
            $null = Invoke-GitlabApi DELETE "projects/$($Project.Id)/members/$($User.Id)" -SiteUrl $SiteUrl
            Write-Host "Removed $($User.Username) from $($Project.Name)"
        }
        catch
        {
            Write-Error "Error removing $($User.Username) from $($Project.Name): $_"
        }
    }
}
