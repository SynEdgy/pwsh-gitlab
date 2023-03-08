
function Remove-GitlabEnvironment
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

        [Parameter()]
        [switch]
        $WhatIf
    )

    process
    {
        $Project = Get-GitlabProject -ProjectId $ProjectId
        $Environment = Get-GitlabEnvironment -ProjectId $Project.Id -Name $Name

        $GitlabApiArguments = @{
            HttpMethod = 'DELETE'
            Path       = "projects/$($Project.Id)/environments/$($Environment.Id)"
            SiteUrl    = $SiteUrl
        }

        $null = Invoke-GitlabApi @GitlabApiArguments -WhatIf:$WhatIf

        # TODO: change to write-Verbose and use -f operator
        Write-Information -InformationAction 'Continue' -MessageData "Environment '$($Environment.Name)' (id: $($Environment.Id)) has been deleted"
    }
}
