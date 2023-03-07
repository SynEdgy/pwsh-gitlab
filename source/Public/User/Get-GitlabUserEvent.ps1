
# https://docs.gitlab.com/ee/api/events.html#get-user-contribution-events

function Get-GitlabUserEvent
{
    [CmdletBinding(DefaultParameterSetName = 'ByUserId')]
    param
    (
        [Parameter(ParameterSetName = 'ByUserId', Mandatory = $false)]
        [Alias('Username')]
        [string]
        $UserId,

        [Parameter(ParameterSetName = 'ByEmail')]
        [string]
        $EmailAddress,

        [Parameter(ParameterSetName='ByMe')]
        [switch]
        $Me,

        [Parameter()]
        [ValidateSet('approved', 'closed', 'commented', 'created', 'destroyed', 'expired', 'joined', 'left', 'merged', 'pushed', 'reopened', 'updated')]
        [string]
        $Action,

        [Parameter()]
        [ValidateSet('issue', 'milestone', 'merge_request', 'note', 'project', 'snippet', 'user')]
        [string]
        $TargetType,

        [Parameter()]
        [ValidateScript({ValidateGitlabDateFormat $_})]
        [string]
        $Before,

        [Parameter()]
        [ValidateScript({ValidateGitlabDateFormat $_})]
        [string]
        $After,

        [Parameter()]
        [ValidateSet('asc', 'desc')]
        [string]
        $Sort,

        [Parameter()]
        [uint]
        $MaxPages = 1,

        [Parameter()]
        [switch]
        $FetchProjects,

        [Parameter()]
        [string]
        $SiteUrl,

        [Parameter()]
        [switch]
        $WhatIf
    )

    $GetUserParams = @{}

    if ($PSCmdlet.ParameterSetName -eq 'ByUserId')
    {
        $GetUserParams.UserId = $UserId
    }

    if ($PSCmdLet.ParameterSetName -eq 'ByEmail')
    {
        $GetUserParams.UserId = $EmailAddress
    }

    if ($PSCmdlet.ParameterSetName -eq 'ByMe')
    {
        $GetUserParams.Me = $true
    }

    $User = Get-GitlabUser @GetUserParams -SiteUrl $SiteUrl

    $Query = @{}
    if ($Before)
    {
        $Query.before = $Before
    }

    if ($After)
    {
        $Query.after = $After
    }

    if ($Action)
    {
        $Query.action = $Action
    }

    if($Sort)
    {
        $Query.sort = $Sort
    }

    $Events = Invoke-GitlabApi GET "users/$($User.Id)/events" -Query $Query -MaxPages $MaxPages -SiteUrl $SiteUrl -WhatIf:$WhatIf |
        New-WrapperObject 'Gitlab.Event'

    if ($FetchProjects)
    {
        $ProjectIds = $Events.ProjectId | Select-Object -Unique
        $Projects = $ProjectIds | ForEach-Object {
            try
            {
                Get-GitlabProject $_ -WhatIf:$WhatIf -SiteUrl $SiteUrl
            }
            catch
            {
                $null
            }
        }

        $Events | ForEach-Object {
            $_ | Add-Member -MemberType 'NoteProperty' -Name 'Project' -Value $($Projects | Where-Object Id -eq $_.ProjectId)
        }
    }

    $Events
}
