
function Get-GitlabPipelineDefinition
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [string]
        $ProjectId = '.',

        [Parameter()]
        [Alias("Branch")]
        [string]
        $Ref,

        [Parameter()]
        [string]
        $SiteUrl,

        [Parameter()]
        [switch]
        $WhatIf
    )

    Get-GitlabRepositoryYmlFileContent -ProjectId $ProjectId -FilePath '.gitlab-ci.yml' -Ref $Ref -SiteUrl $SiteUrl
}
