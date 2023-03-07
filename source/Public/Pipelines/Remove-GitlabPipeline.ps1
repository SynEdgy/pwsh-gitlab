
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

        [switch]
        [Parameter()]
        $WhatIf
    )

    $Project = Get-GitlabProject $ProjectId -SiteUrl $SiteUrl
    $Pipeline = Get-GitlabPipeline -ProjectId $ProjectId -PipelineId $PipelineId -SiteUrl $SiteUrl

    Invoke-GitlabApi DELETE "projects/$($Project.Id)/pipelines/$($Pipeline.Id)" -SiteUrl $SiteUrl -WhatIf:$WhatIf | Out-Null

    if (-not $WhatIf)
    {
        Write-Host "$PipelineId deleted from $($Project.Name)"
    }
}
