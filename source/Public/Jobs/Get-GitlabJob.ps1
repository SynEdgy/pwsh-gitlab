
function Get-GitlabJob
{
    [Alias('job')]
    [Alias('jobs')]
    [CmdletBinding()]
    param
    (
        [Parameter(ParameterSetName = 'ByJobId')]
        [Parameter(ParameterSetName = 'ByProjectId', ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = 'ByPipeline', ValueFromPipelineByPropertyName = $true)]
        [string]
        $ProjectId = '.',

        [Parameter(ParameterSetName = 'ByPipeline', ValueFromPipelineByPropertyName = $true)]
        [string]
        $PipelineId,

        [Parameter(ParameterSetName = 'ByJobId', Mandatory = $true)]
        [string]
        $JobId,

        [Parameter()]
        [ValidateSet("created","pending","running","failed","success","canceled","skipped","manual")]
        [string]
        $Scope,

        [Parameter()]
        [string]
        $Stage,

        [Parameter()]
        [string]
        $Name,

        [Parameter()]
        [switch]
        $IncludeRetried,

        [Parameter()]
        [switch]
        $IncludeTrace,

        [Parameter()]
        [string]
        $SiteUrl,

        [switch]
        [Parameter()]
        $WhatIf
    )

    $Project = Get-GitlabProject $ProjectId
    $ProjectId = $Project.Id

    $GitlabApiArguments = @{
        HttpMethod = "GET"
        Query      = @{}
        Path       = "projects/$ProjectId/jobs"
        SiteUrl    = $SiteUrl
    }

    if ($PipelineId)
    {
        $GitlabApiArguments.Path = "projects/$ProjectId/pipelines/$PipelineId/jobs"
    }

    if ($JobId)
    {
        $GitlabApiArguments.Path = "projects/$ProjectId/jobs/$JobId"
    }

    if ($Scope)
    {
        $GitlabApiArguments['Query']['scope'] = $Scope
    }

    if ($IncludeRetried)
    {
        $GitlabApiArguments['Query']['include_retried'] = $true
    }

    $Jobs = Invoke-GitlabApi @GitlabApiArguments -WhatIf:$WhatIf | New-WrapperObject 'Gitlab.Job'

    if ($Stage)
    {
        $Jobs = $Jobs |
            Where-Object Stage -match $Stage
    }

    if ($Name)
    {
        $Jobs = $Jobs |
            Where-Object Name -match $Name
    }

    if ($IncludeTrace)
    {
        $Jobs | ForEach-Object {
            try
            {
                $Trace = $_ | Get-GitlabJobTrace -WhatIf:$WhatIf
            }
            catch
            {
                $Trace = $Null
            }

            $_ | Add-Member -MemberType 'NoteProperty' -Name 'Trace' -Value $Trace
        }
    }

    $Jobs
}
