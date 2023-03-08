
function Remove-GitlabPipeline
{
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]
        $ProjectId = '.',

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]
        $PipelineId,

        [Parameter()]
        [string]
        $SiteUrl,

        [Parameter()]
        [switch]
        $WhatIf
    )

    $Project = Get-GitlabProject $ProjectId -SiteUrl $SiteUrl
    $Pipeline = Get-GitlabPipeline -ProjectId $ProjectId -PipelineId $PipelineId -SiteUrl $SiteUrl

    Invoke-GitlabApi -HttpMethod 'DELETE' -Path "projects/$($Project.Id)/pipelines/$($Pipeline.Id)" -SiteUrl $SiteUrl -WhatIf:$WhatIf | Out-Null

    if (-not $WhatIf)
    {
        Write-Information -InformationAction 'Continue' -MessageData "$PipelineId deleted from $($Project.Name)"
    }
}
