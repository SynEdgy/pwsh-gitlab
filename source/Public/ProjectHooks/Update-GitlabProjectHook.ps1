
# https://docs.gitlab.com/ee/api/projects.html#hooks

function Update-GitlabProjectHook
{
    param
    (
      [Parameter(ValueFromPipelineByPropertyName = $true)]
      [string]
      $ProjectId = '.',

      [Parameter(Mandatory = $true)]
      [int]
      $Id,

      [Parameter(Mandatory = $true)]
      [string]
      $Url,

      [Parameter()]
      [bool]
      $ConfidentialIssuesEvents,

      [Parameter()]
      [bool]
      $ConfidentialNoteEvents,

      [Parameter()]
      [bool]
      $DeploymentEvents,

      [Parameter()]
      [bool]
      $EnableSSLVerification,

      [Parameter()]
      [bool]
      $IssuesEvents,

      [Parameter()]
      [bool]
      $JobEvents,

      [Parameter()]
      [bool]
      $MergeRequestsEvents,

      [Parameter()]
      [bool]
      $NoteEvents,

      [Parameter()]
      [bool]
      $PipelineEvents,

      [Parameter()]
      [string]
      $PushEventsBranchFilter,

      [Parameter()]
      [bool]
      $PushEvents,

      [Parameter()]
      [bool]
      $ReleasesEvents,

      [Parameter()]
      [bool]
      $TagPushEvents,

      [Parameter()]
      [string]
      $Token,

      [Parameter()]
      [bool]
      $WikiPageEvents,

      [Parameter()]
      [string]
      $SiteUrl,

      [Parameter()]
      [switch]
      $WhatIf
    )

    $Project = Get-GitlabProject $ProjectId -SiteUrl $SiteUrl -WhatIf:$WhatIf

    $Resource = "projects/$($Project.Id)/hooks/$($Id)"

    $Request = @{
        url                        = $Url
        confidential_issues_events = $ConfidentialIssuesEvents
        confidential_note_events   = $ConfidentialNoteEvents
        deployment_events          = $DeploymentEvents
        enable_ssl_verification    = $EnableSSLVerification
        issues_events              = $IssuesEvents
        job_events                 = $JobEvents
        merge_requests_events      = $MergeRequestsEvents
        note_events                = $NoteEvents
        pipeline_events            = $PipelineEvents
        push_events                = $PushEvents
        releases_events            = $ReleasesEvents
        tag_push_events            = $TagPushEvents
        wiki_page_events           = $WikiPageEvents
    }

    if ($PushEventsBranchFilter)
    {
        $Request += @{
            push_events_branch_filter = $PushEventsBranchFilter
        }
    }

    if ($Token)
    {
        $Request += @{
            token = $Token
        }
    }

    Invoke-GitlabApi -HttpMethod 'PUT' -Path $UpdateRequest $Resource -SiteUrl $SiteUrl -WhatIf:$WhatIf | New-WrapperObject 'Gitlab.ProjectHook'
  }
