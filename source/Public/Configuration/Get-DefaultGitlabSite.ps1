
function Get-DefaultGitlabSite
{
    [CmdletBinding()]
    param
    (
        #
    )

    $Configuration = Get-GitlabConfiguration
    $LocalContext = Get-LocalGitContext

    if ($LocalContext.Site)
    {
        $MatchingSite = $Configuration.Sites | Where-Object Url -eq $LocalContext.Site
        if ($MatchingSite)
        {
            return $MatchingSite | Select-Object -First 1
        }
    }

    $Configuration | Select-Object -ExpandProperty Sites | Where-Object IsDefault | Select-Object -First 1
}
