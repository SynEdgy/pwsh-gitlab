
# https://docs.gitlab.com/ee/api/audit_events.html
function Get-GitlabAuditEvent
{
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $ProjectId,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $GroupId,

        [Parameter()]
        [string]
        $AuditEventId,

        [Parameter()]
        [ValidateSet('User', 'Group', 'Project', IgnoreCase=$false)]
        [string]
        $EntityType,

        [Parameter()]
        [string]
        $EntityId,

        [Parameter()]
        [switch]
        $FetchAuthors,

        [Parameter()]
        [switch]
        $All,

        [Parameter()]
        [Alias('Until')]
        [ValidateScript({ValidateGitlabDateFormat $_})]
        [string]
        $Before,

        [Parameter()]
        [Alias('Since')]
        [ValidateScript({ValidateGitlabDateFormat $_})]
        [string]
        $After,

        [Parameter()]
        [int]
        $MaxPages = $GitlabGetProjectDefaultPages,

        [Parameter()]
        [string]
        $SiteUrl
    )

    if ($All)
    {
        if ($MaxPages -ne $GitlabGetProjectDefaultPages)
        {
            Write-Warning -Message "Ignoring -MaxPages in favor of -All"
        }

        $MaxPages = [uint]::MaxValue
    }

    if ($GroupId)
    {
        $Group = Get-GitlabGroup $GroupId
        $Resource = "groups/$($Group.Id)/audit_events"
    }
    elseif ($ProjectId)
    {
        $Project = Get-GitlabProject $ProjectId
        $Resource = "projects/$($Project.Id)/audit_events"
    }
    else
    {
        $Resource = 'audit_events'
    }

    if ($AuditEventId)
    {
        $Resource += "/$AuditEventId"
    }

    $Query = @{}
    if ($EntityId)
    {
        if (-not $EntityType)
        {
            throw "Requires -EntityType to also be provided"
        }

        $Query.entity_id = $EntityId
    }

    if ($EntityType)
    {
        $Query.entity_type = $EntityType
    }

    if ($Before)
    {
        $Query.created_before = $Before
    }

    if ($After)
    {
        $Query.created_after = $After
    }

    $Results = Invoke-GitlabApi -HttpMethod 'GET' -Path $Resource -Query $Query -MaxPages $MaxPages -SiteUrl $SiteUrl | New-WrapperObject 'Gitlab.AuditEvent'

    if ($FetchAuthors)
    {
        $Authors = $Results.AuthorId | Select-Object -Unique | Where-Object { $_ -ne '-1' } | ForEach-Object {
            try
            {
                $User = Get-GitlabUser $_
            }
            catch
            {
                $User = $null
            }

            @{
                Id   = $_
                User = $User
            }
        }

        $Results | ForEach-Object {
            $_ | Add-Member -MemberType 'NoteProperty' -Name 'Author' -Value $($Authors | Where-Object Id -eq $_.AuthorId | Select-Object -ExpandProperty User)
        }
    }

    $Results
}
