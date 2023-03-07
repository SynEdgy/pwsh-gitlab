
# https://docs.gitlab.com/ee/api/members.html#edit-a-member-of-a-group-or-project
function Update-GitlabUserMembership
{
    [CmdletBinding(SupportsShouldProcess = $true, DefaultParameterSetName = 'Group')]
    param
    (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        $Username,

        [Parameter(ParameterSetName = 'Group', Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        $GroupId,

        [Parameter(ParameterSetName = 'Project', Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        $ProjectId,

        [Parameter(Mandatory = $true)]
        [ValidateSet('developer', 'maintainer', 'owner')]
        [string]
        $AccessLevel,

        [Parameter()]
        [string]
        $SiteUrl
    )

    $User = Get-GitlabUser -UserId $Username

    $Rows = @()

    $AccessLevelLiteral = Get-GitlabMemberAccessLevel $AccessLevel

    switch ($PSCmdlet.ParameterSetName)
    {
        Group {
            $Group = Get-GitlabGroup -GroupId $GroupId
            if ($PSCmdLet.ShouldProcess($Group.FullName, "update $($User.Username)'s membership access level to '$AccessLevel' on group"))
            {
                $Rows = Invoke-GitlabApi PUT "groups/$($Group.Id)/members/$($User.Id)" @{
                    access_level = $AccessLevelLiteral
                } -SiteUrl $SiteUrl
            }
        }

        Project {
            $Project = Get-GitlabProject -ProjectId $ProjectId
            if ($PSCmdLet.ShouldProcess($Project.PathWithNamespace, "update $($User.Username)'s membership access level to '$AccessLevel' on project"))
            {
                $Rows = Invoke-GitlabApi PUT "projects/$($Project.Id)/members/$($User.Id)" @{
                    access_level = $AccessLevelLiteral
                }  -SiteUrl $SiteUrl
            }
        }
    }

    $Rows | New-WrapperObject 'Gitlab.Member'
}
