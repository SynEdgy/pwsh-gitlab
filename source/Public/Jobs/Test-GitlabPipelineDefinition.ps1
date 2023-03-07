
function Test-GitlabPipelineDefinition
{
    [CmdletBinding(DefaultParameterSetName = 'Project')]
    param
    (
        [Parameter(ParameterSetName = 'Project')]
        [string]
        $ProjectId = '.',

        [Parameter(Mandatory = $true, ParameterSetName = 'Content')]
        [string]
        $Content,

        [Parameter()]
        [string]
        $Select,

        [Parameter()]
        [string]
        $SiteUrl,

        [switch]
        [Parameter()]
        $WhatIf
    )

    $Project = Get-GitlabProject $ProjectId
    $ProjectId = $Project.Id

    $Params = @{
        Body    = @{}
        Query   = @{}
        SiteUrl = $SiteUrl
        WhatIf  = $WhatIf
    }

    switch ($PSCmdlet.ParameterSetName)
    {
        Content {
            if (Test-Path $Content)
            {
                $Content = Get-Content -Raw -Path $Content
            }

            # https://docs.gitlab.com/ee/api/lint.html#validate-the-ci-yaml-configuration
            $Params.HttpMethod                = 'POST'
            $Params.Path                      = 'ci/lint'
            $Params.Body.content              = $Content
            $Params.Query.include_merged_yaml = 'true'
        }

        Default {
            # https://docs.gitlab.com/ee/api/lint.html#validate-a-projects-ci-configuration
            $Params.HttpMethod = 'GET'
            $Params.Path = "projects/$ProjectId/ci/lint"
        }
    }

    Invoke-GitlabApi @Params |
        New-WrapperObject 'Gitlab.PipelineDefinition' |
        Get-FilteredObject $Select
}
