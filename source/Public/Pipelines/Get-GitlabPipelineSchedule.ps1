
function Get-GitlabPipelineSchedule
{
    [CmdletBinding(DefaultParameterSetName = 'ByProjectId')]
    [Alias('schedule')]
    [Alias('schedules')]
    param
    (
        [Parameter(ParameterSetName = 'ByProjectId', ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = 'ByPipelineScheduleId')]
        [string]
        $ProjectId = '.',

        [Parameter(ParameterSetName = 'ByPipelineScheduleId', Mandatory = $true)]
        [Alias('Id')]
        [int]
        $PipelineScheduleId,

        [Parameter(ParameterSetName = 'ByProjectId')]
        [ValidateSet('active', 'inactive')]
        [string]
        $Scope,

        [Parameter(ParameterSetName = 'ByProjectId', ValueFromPipelineByPropertyName = $true)]
        [switch]
        $IncludeVariables,

        [Parameter()]
        [string]
        $SiteUrl,

        [switch]
        [Parameter()]
        $WhatIf
    )

    $ProjectId = (Get-GitlabProject -ProjectId $ProjectId).Id

    $GitlabApiArguments = @{
        HttpMethod = 'GET'
        Path       = "projects/$ProjectId/pipeline_schedules"
        Query      = @{}
        SiteUrl    = $SiteUrl
    }

    switch ($PSCmdlet.ParameterSetName)
    {
        ByPipelineScheduleId {
            $GitlabApiArguments.Path += "/$PipelineScheduleId"
        }

        ByProjectId {
            if($Scope)
            {
                $GitlabApiArguments.Query.scope = $Scope
            }
        }

        default { throw "Parameterset $($PSCmdlet.ParameterSetName) is not implemented"}
    }

    $Wrapper = Invoke-GitlabApi @GitlabApiArguments -WhatIf:$WhatIf | New-WrapperObject 'Gitlab.PipelineSchedule'
    $Wrapper | Add-Member -MemberType 'NoteProperty' -Name 'ProjectId' -Value $ProjectId

    #Because the api only includes variables when requesting the pipeline schedule by id. Do a little recursion
    #Switch is only part of the ByProjectId parameter set
    if($IncludeVariables)
    {
        $Wrapper = $Wrapper | ForEach-Object {Get-GitlabPipelineSchedule -ProjectId $_.ProjectId -PipelineScheduleId $_.Id  }
    }

    $Wrapper
}
