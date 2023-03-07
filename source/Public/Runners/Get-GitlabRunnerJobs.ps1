function Get-GitlabRunnerJobs
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]
        $RunnerId,

        [Parameter()]
        [int]
        $MaxPages = 1,

        [Parameter()]
        [string]
        $SiteUrl,

        [switch]
        [Parameter()]
        $WhatIf
    )

    $Params = @{
        HttpMethod = 'GET'
        Path       = "runners/$RunnerId/jobs"
        MaxPages   = $MaxPages
        SiteUrl    = $SiteUrl
        WhatIf     = $WhatIf
    }

    Invoke-GitlabApi @Params | New-WrapperObject 'Gitlab.RunnerJob'
}
