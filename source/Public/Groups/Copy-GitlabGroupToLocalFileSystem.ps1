
function Copy-GitlabGroupToLocalFileSystem
{
    [Alias("Clone-GitlabGroup")]
    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        $GroupId,

        [Parameter()]
        [string]
        $ProjectLike,

        [Parameter()]
        [string]
        $ProjectNotLike,

        [Parameter()]
        [string]
        $SiteUrl
    )

    $Group = Get-GitlabGroup $GroupId

    if ($PSCmdlet.ShouldProcess($Group.FullPath, "clone group" ))
    {
        $GroupSplit = $Group.FullPath -split '/'

        $OriginalPath = $LocalPath = $(Get-Location).Path
        for ($i = 0; $i -lt $GroupSplit.Count; $i++)
        {
            $ToMatch = $($GroupSplit | Select-Object -First $($GroupSplit.Count - $i)) -join '/'
            if ($LocalPath -imatch "$ToMatch$")
            {
                $LocalPath = $LocalPath.Replace($ToMatch, "").TrimEnd('/')
                break;
            }
        }

        $Projects = Get-GitlabProject -GroupId $GroupId -Recurse -All

        if ($ProjectLike)
        {
            $Projects = $Projects | Where-Object PathWithNamespace -Match $ProjectLike
        }

        if ($ProjectNotLike)
        {
            $Projects = $Projects | Where-Object PathWithNamespace -NotMatch $ProjectNotLike
        }

        $Projects | ForEach-Object {
            $Path = "$LocalPath/$($_.Group)"

            if (-not $(Test-Path $Path))
            {
                $null = New-Item $Path -Type Directory
            }

            Set-Location $Path
            git clone $_.SshUrlToRepo
        }

        Set-Location $OriginalPath
    }
}
