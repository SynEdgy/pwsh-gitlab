
function Start-GitlabJob
{
    [Alias('Play-GitlabJob')]
    [Alias('play')]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]
        $JobId,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]
        $ProjectId = '.',

        [Parameter()]
        [string]
        $SiteUrl,

        [Parameter()]
        [switch]
        $WhatIf
    )

    $ProjectId = $(Get-GitlabProject -ProjectId $ProjectId).Id

    $GitlabApiArguments = @{
        HttpMethod = "POST"
        Path       = "projects/$ProjectId/jobs/$JobId/play"
        SiteUrl    = $SiteUrl
    }

    try
    {
        Invoke-GitlabApi @GitlabApiArguments -WhatIf:$WhatIf | New-WrapperObject "Gitlab.Job"
    }
    catch
    {
        if ($_.ErrorDetails.Message -match 'Unplayable Job')
        {
            $GitlabApiArguments.Path = $GitlabApiArguments.Path -replace '/play', '/retry'
            Invoke-GitlabApi @GitlabApiArguments -WhatIf:$WhatIf | New-WrapperObject "Gitlab.Job"
        }
    }
}
