if ($PSVersionTable.Platform -like 'Win*')
{
    $env:HOME = Join-Path -Path $env:HOMEDRIVE
}

$GitlabConfigurationPath = Join-Path -Path $env:HOME -ChildPath '.config/powershell/gitlab.config'
$GitlabJobLogSections = New-Object 'Collections.Generic.Stack[string]'
$GitlabGetProjectDefaultPages = 10
$GitlabSearchResultsDefaultLimit = 100

# https://docs.gitlab.com/ee/api/#id-vs-iid
# TL;DR; it's a mess and we have to special-case specific entity types
$global:GitlabIdentityPropertyNameExemptions=@{
    'Gitlab.AuditEvent'                = 'Id'
    'Gitlab.AccessToken'               = 'Id'
    'Gitlab.BlobSearchResult'          = ''
    'Gitlab.Branch'                    = ''
    'Gitlab.Commit'                    = 'Id'
    'Gitlab.Configuration'             = ''
    'Gitlab.Environment'               = 'Id'
    'Gitlab.Event'                     = 'Id'
    'Gitlab.Group'                     = 'Id'
    'Gitlab.ProjectIntegration'        = 'Id'
    'Gitlab.Job'                       = 'Id'
    'Gitlab.Member'                    = 'Id'
    'Gitlab.MergeRequestApprovalRule'  = 'Id'
    'Gitlab.Note'                      = 'Id'
    'Gitlab.Pipeline'                  = 'Id'
    'Gitlab.PipelineBridge'            = 'Id'
    'Gitlab.PipelineDefinition'        = ''
    'Gitlab.PipelineSchedule'          = 'Id'
    'Gitlab.PipelineScheduleVariable'  = ''
    'Gitlab.Project'                   = 'Id'
    'Gitlab.ProjectHook'               = 'Id'
    'Gitlab.ProtectedBranch'           = 'Id'
    'Gitlab.RepositoryFile'            = ''
    'Gitlab.RepositoryTree'            = ''
    'Gitlab.Runner'                    = 'Id'
    'Gitlab.RunnerJob'                 = 'Id'
    'Gitlab.SearchResult.Blob'         = ''
    'Gitlab.SearchResult.MergeRequest' = ''
    'Gitlab.SearchResult.Project'      = ''
    'Gitlab.Topic'                     = 'Id'
    'Gitlab.User'                      = 'Id'
    'Gitlab.UserMembership'            = ''
    'Gitlab.Variable'                  = ''
}
