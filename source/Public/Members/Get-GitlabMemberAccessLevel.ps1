# https://docs.gitlab.com/ee/api/members.html#valid-access-levels
function Get-GitlabMemberAccessLevel
{
    param
    (
        [Parameter(Position = 0)]
        [string]
        $AccessLevel
    )

    $Levels = [PSCustomObject]@{
        NoAccess      = 0
        MinimalAccess = 5
        Guest         = 10
        Reporter      = 20
        Developer     = 30
        Maintainer    = 40
        Owner         = 50
    }

    if ($AccessLevel)
    {
        $Levels.$AccessLevel
    }
    else
    {
        $Levels
    }
}
