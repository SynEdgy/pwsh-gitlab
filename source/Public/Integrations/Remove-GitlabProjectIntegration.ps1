
function Remove-GitlabProjectIntegration
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]
        $ProjectId = '.',

        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateSet('slack')]
        [string]
        $Integration,

        [Parameter()]
        [string]
        $SiteUrl
    )

    $Project = Get-GitlabProject $ProjectId -SiteUrl $SiteUrl

    $Resource = "projects/$($Project.Id)/integrations/$Integration"

    if ($PSCmdlet.ShouldProcess("$Resource", "delete"))
    {
        $null = Invoke-GitlabApi -HttpMethod 'DELETE' -Path $Resource -Body $Settings -SiteUrl $SiteUrl
        Write-Information -InformationAction 'Continue' -MessageData "Deleted $Integration integration from $($Project.PathWithNamespace)"
    }
}
