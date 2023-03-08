# https://docs.gitlab.com/ee/api/projects.html#hooks
function Get-GitlabProjectHook
{
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]
        $ProjectId = '.',

        [Parameter()]
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

    $Resource = "projects/$($Project.Id)/hooks"

    if ($Id)
    {
      $Resource = "$($Resource)/$($Id)"
    }

    Invoke-GitlabApi -HttpMethod 'GET' -Path $Resource -SiteUrl $SiteUrl -WhatIf:$WhatIf | New-WrapperObject 'Gitlab.ProjectHook'
  }
