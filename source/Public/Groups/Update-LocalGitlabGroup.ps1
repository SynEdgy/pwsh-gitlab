function Update-LocalGitlabGroup
{
    [Alias("Pull-GitlabGroup")]
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [switch]
        $WhatIf
    )

    Get-ChildItem -Recurse -Hidden -Directory |
        Where-Object Name -match '.git$' |
        ForEach-Object {
            Push-Location #TODO: use a stackname

            if ($WhatIf.IsPresent)
            {
                Write-Host "WhatIf: git pull -p '$_'"
            }
            else
            {
                Set-Location -Path "$_/.."
                git pull -p
            }

            Pop-Location
    }
}
