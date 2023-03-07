
function Get-GitlabJobTrace
{
    [Alias('trace')]
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]
        $ProjectId = '.',

        [Parameter(Position = 0, Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        $JobId,

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
        Path       = "projects/$ProjectId/jobs/$JobId/trace"
        SiteUrl    = $SiteUrl
    }

    Invoke-GitlabApi @GitlabApiArguments -WhatIf:$WhatIf
}
