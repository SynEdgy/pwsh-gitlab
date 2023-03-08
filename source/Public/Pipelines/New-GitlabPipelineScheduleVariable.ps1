
function New-GitlabPipelineScheduleVariable
{
    param
    (
        [Parameter()]
        [string]
        $ProjectId="." ,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [int]
        $PipelineScheduleId,

        [Parameter(Mandatory = $true)]
        [ValidatePattern("[A-Za-z0-9_]")]
        [string]
        $Key,

        [Parameter(Mandatory = $true)]
        [string]
        $Value,

        [Parameter()]
        [ValidateSet("env_var","file")]
        [string]
        $VariableType = "env_var",

        [Parameter()]
        [string]
        $SiteUrl,

        [Parameter()]
        [switch]
        $WhatIf
    )

    $Project = Get-GitlabProject $ProjectId -SiteUrl $SiteUrl
    $PipelineSchedule = Get-GitlabPipelineSchedule -ProjectId $Project.Id -PipelineScheduleId $PipelineScheduleId

    $Body = @{
        "key"           = $Key
        "value"         = $Value
        "variable_type" = $VariableType
    }

    $GitlabApiArguments = @{
        HttpMethod = "POST"
        Path       = "projects/$($Project.Id)/pipeline_schedules/$($PipelineSchedule.Id)/variables"
        SiteUrl    = $SiteUrl
        Body       = $Body
    }

    Invoke-GitlabApi @GitlabApiArguments -WhatIf:$WhatIf | New-WrapperObject "Gitlab.PipelineScheduleVariable"
    $Wrapper | Add-Member -MemberType 'NoteProperty' -Name 'ProjectId' -Value $Project.Id
    $Wrapper | Add-Member -MemberType 'NoteProperty' -Name 'PipelineScheduleId' -Value $PipelineSchedule.Id
}
