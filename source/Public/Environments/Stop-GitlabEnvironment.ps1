
function Stop-GitlabEnvironment
{
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]
        $ProjectId = '.',

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        $Name,

        [Parameter()]
        [string]
        $SiteUrl,

        [switch]
        [Parameter()]
        $WhatIf
    )

    process
    {
        $Project = Get-GitlabProject -ProjectId $ProjectId
        $Environment = Get-GitlabEnvironment -ProjectId $Project.Id -Name $Name

        $GitlabApiArguments = @{
            HttpMethod='POST'
            Path="projects/$($Project.Id)/environments/$($Environment.Id)/stop"
            SiteUrl = $SiteUrl
        }

        $null = Invoke-GitlabApi @GitlabApiArguments -WhatIf:$WhatIf

        Write-Host "Environment '$($Environment.Name)' (id: $($Environment.Id)) has been stopped"
    }
}
