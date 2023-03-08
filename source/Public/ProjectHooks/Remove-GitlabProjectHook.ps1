
# https://docs.gitlab.com/ee/api/projects.html#hooks

function Remove-GitlabProjectHook
{
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]
        $ProjectId = '.',

        [Parameter(Mandatory = $true)]
        [int]
        $Id,

        [Parameter()]
        [string]
        $SiteUrl,

        [Parameter()]
        [switch]
        $WhatIf
    )

    $Project = Get-GitlabProject $ProjectId -SiteUrl $SiteUrl -WhatIf:$WhatIf
    $Resource = "projects/$($Project.Id)/hooks/$($Id)"
    Invoke-GitlabApi -HttpMethod 'DELETE' -Path $Resource -SiteUrl $SiteUrl -WhatIf:$WhatIf
  }
