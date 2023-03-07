
function Remove-GitlabSite
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $Url
    )

    if (Test-IsConfigurationEnvironmentVariables)
    {
        Write-Warning "GitlabCli: Current configuration is from environment variables"
        Write-Warning "Unset `$env:GITLAB_ACCESS_TOKEN to use file-based configuration"
        return
    }

    $Config = Get-GitlabConfiguration
    $Config.Sites = $Config.Sites | Where-Object Url -ne $Url

    $Config | Write-GitlabConfiguration

    Get-GitlabConfiguration
}
