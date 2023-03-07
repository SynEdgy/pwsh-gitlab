function Set-DefaultGitlabSite
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [string]
        $Url
    )

    if (Test-IsConfigurationEnvironmentVariables)
    {
        Write-Warning "GitlabCli: Current configuration is from environment variables which only supports a single site"
        Write-Warning "Unset `$env:GITLAB_ACCESS_TOKEN to use file-based configuration option"
        return
    }

    $Config = Get-GitlabConfiguration
    $Site = $Config.Sites | Where-Object Url -eq $Url

    if (-not $Site)
    {
        throw "'$Url' site not found"
    }

    $Config.Sites | ForEach-Object {
        $_.IsDefault = $false
    }

    $Site.IsDefault = $true
    $Config | Write-GitlabConfiguration
}
