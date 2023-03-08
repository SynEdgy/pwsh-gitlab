
# https://docs.gitlab.com/ee/api/members.html#list-all-members-of-a-group-or-project
function Get-GitlabProjectMember
{
    param
    (
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]
        $ProjectId = '.',

        [Parameter()]
        [Alias('Username')]
        [string]
        $UserId,

        [Parameter()]
        [switch]
        $All,

        [Parameter()]
        [int]
        $MaxPages = 10,

        [Parameter()]
        [string]
        $SiteUrl
    )

    $Project = Get-GitlabProject -ProjectId $ProjectId -SiteUrl $SiteUrl

    if ($UserId)
    {
        $User = Get-GitlabUser -UserId $UserId -SiteUrl $SiteUrl
    }

    $Members = $All ? "members/all" : "members"
    $Resource = $User ? "projects/$($Project.Id)/$Members/$($User.Id)" : "projects/$($Project.Id)/$Members"

    Invoke-GitlabApi -HttpMethod 'GET' -Path $Resource -MaxPages $MaxPages -SiteUrl $SiteUrl |
        New-WrapperObject 'Gitlab.Member'
}
