
function Rename-GitlabProjectDefaultBranch
{
    param
    (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]
        $NewDefaultBranch,

        [Parameter()]
        [string]
        $SiteUrl,

        [Parameter()]
        [switch]
        $WhatIf
    )

    $Project = Get-GitlabProject -ProjectId '.'
    if (-not $Project)
    {
        throw "This cmdlet requires being run from within a gitlab project"
    }

    if ($Project.DefaultBranch -ieq $NewDefaultBranch)
    {
        throw "Default branch for $($Project.Name) is already $($Project.DefaultBranch)"
    }

    $OldDefaultBranch = $Project.DefaultBranch

    if ($WhatIf)
    {
        Write-Information -InformationAction 'Continue' -MessageData "WhatIf: would change default branch for $($Project.PathWithNamespace) from $OldDefaultBranch to $NewDefaultBranch"
        return
    }

    $null = git checkout $OldDefaultBranch
    $null = git pull -p
    $null = git branch -m $OldDefaultBranch $NewDefaultBranch
    $null = git push -u origin $NewDefaultBranch -o ci.skip
    $null = Update-GitlabProject -DefaultBranch $NewDefaultBranch -SiteUrl $SiteUrl -WhatIf:$WhatIf

    try
    {
        $null = UnProtect-GitlabBranch -Name $OldDefaultBranch -SiteUrl $SiteUrl -WhatIf:$WhatIf
    }
    catch
    {
        Write-Debug -Message ('Exception Caught: {0}' -f $_)
    }

    $null = Protect-GitlabBranch -Name $NewDefaultBranch -SiteUrl $SiteUrl -WhatIf:$WhatIf
    $null = git push --delete origin $OldDefaultBranch
    $null = git remote set-head origin -a

    Get-GitlabProject -ProjectId $Project.Id
}
