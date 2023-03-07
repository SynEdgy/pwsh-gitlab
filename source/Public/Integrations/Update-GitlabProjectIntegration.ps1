
function Update-GitlabProjectIntegration
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

        # NOTE: generally we don't want accept raw API semantics, but given each integration is modeled differently...
        [Parameter(Position = 1, Mandatory = $true)]
        [hashtable]
        $Settings,

        [Parameter()]
        [string]
        $SiteUrl
    )

    $Project = Get-GitlabProject $ProjectId -SiteUrl $SiteUrl

    $Resource = "projects/$($Project.Id)/integrations/$Integration"

    if ($PSCmdlet.ShouldProcess("$Resource", "update $($Settings | ConvertTo-Json)"))
    {
        Invoke-GitlabApi PUT $Resource -Body $Settings -SiteUrl $SiteUrl | New-WrapperObject 'Gitlab.ProjectIntegration'
    }
}
