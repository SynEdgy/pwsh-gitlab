
function Write-GitlabConfiguration
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        # TODO: what type of object is $Configuration?
        [Object]
        $Configuration
    )

    $ToSave = $Configuration |
        Select-Object -ExcludeProperty '*Display'

    try
    {
        # fun with cardinality
        if (-not ($ToSave.Sites -is [array]))
        {
            $ToSave.Sites = @($ToSave.Sites)
        }
    }
    catch [System.Management.Automation.PropertyNotFoundException]
    {
        # if there is no Sites yet (and $ToSave is $null, probably), make an empty config
        $ToSave = @{
            Sites = @()
        }
    }

    $ConfigContainer = Split-Path -Parent -Path $GitlabConfigurationPath

    if (-not (Test-Path -Type Container $ConfigContainer))
    {
        $null = New-Item -Type Directory $ConfigContainer
    }

    $null = $ToSave |
        ConvertTo-Json |
        Set-Content -Path $GitlabConfigurationPath -Force
}
