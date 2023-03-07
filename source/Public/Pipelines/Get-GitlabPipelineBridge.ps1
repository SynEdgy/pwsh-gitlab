
# https://docs.gitlab.com/ee/api/jobs.html#list-pipeline-bridges
function Get-GitlabPipelineBridge
{
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]
        $ProjectId = '.',

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        $PipelineId,

        [Parameter(Mandatory=$false)]
        [string]
        [ValidateSet("created","pending","running","failed","success","canceled","skipped","manual")]
        $Scope,

        [Parameter(Mandatory=$false)]
        [string]
        $SiteUrl,

        [switch]
        [Parameter(Mandatory=$false)]
        $WhatIf
    )

    $ProjectId = $(Get-GitlabProject -ProjectId $ProjectId).Id

    $GitlabApiArguments = @{
        HttpMethod = "GET"
        Path       = "projects/$ProjectId/pipelines/$PipelineId/bridges"
        Query      = @{}
        SiteUrl    = $SiteUrl
    }

    if($Scope)
    {
        $GitlabApiArguments['Query']['scope'] = $Scope
    }

    Invoke-GitlabApi @GitlabApiArguments -WhatIf:$WhatIf | New-WrapperObject "Gitlab.PipelineBridge"
}
