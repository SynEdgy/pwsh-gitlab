

function Get-GitlabConfiguration
{
    [CmdletBinding()]
    param
    (
        #
    )

    if (Test-IsConfigurationEnvironmentVariables)
    {
        return [PSCustomObject]@{
            Sites = @(@{
                Url = $env:GITLAB_URL ?? 'gitlab.com' # THIS IS PSv5 only
                AccessToken = $env:GITLAB_ACCESS_TOKEN
                IsDefault = $true
            })
        } | New-WrapperObject 'Gitlab.Configuration'
    }

    if (-not (Test-Path $GitlabConfigurationPath))
    {
        Write-Warning "GitlabCli: Creating blank configuration file '$GitlabConfigurationPath'"

        @{
            Sites = @()
        } | Write-GitlabConfiguration
    }

    Get-Content $GitlabConfigurationPath | ConvertFrom-Json | New-WrapperObject 'Gitlab.Configuration'
}
