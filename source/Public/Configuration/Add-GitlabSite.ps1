

function Add-GitlabSite {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $Url,

        [Parameter(Mandatory = $true)]
        [string]
        $AccessToken,

        [Parameter()]
        [switch]
        $IsDefault
    )

    if (Test-IsConfigurationEnvironmentVariables)
    {
        Write-Warning "GitlabCli: Current configuration is from environment variables"
        Write-Warning "Unset `$env:GITLAB_ACCESS_TOKEN to use file-based configuration"
        return
    }

    $Config = Get-GitlabConfiguration
    $ExistingSite = $Config.Sites | Where-Object Url -eq $Url
    if ($ExistingSite)
    {
        #TODO: supports should process
        if ($(Read-Host -Prompt "Configuration for '$Url' already exists -- replace it? [y/n]") -ieq 'y')
        {
            Remove-GitlabSite $Url
            $Config = Get-GitlabConfiguration
        }
        else
        {
            return
        }
    }

    $Config.Sites += @{
        Url = $Url
        AccessToken = $AccessToken
        IsDefault = 'false'
    }

    $Config | Write-GitlabConfiguration

    if ($IsDefault)
    {
        Set-DefaultGitlabSite -Url $Url
    }

    Get-GitlabConfiguration #TODO: Passthru?
}
