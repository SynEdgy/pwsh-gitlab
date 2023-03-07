
function New-GitlabRepositoryFile
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [string]
        $ProjectId = '.',

        [Parameter()]
        [string]
        $Branch,

        [Parameter(Position = 0, Mandatory = $true)]
        [string]
        $FilePath,

        [Parameter(Mandatory = $true)]
        [string]
        $Content,

        [Parameter(Mandatory = $true)]
        [string]
        $CommitMessage,

        [Parameter()]
        [bool]
        $SkipCi = $true,

        [Parameter()]
        [string]
        $SiteUrl,

        [Parameter()]
        [switch]
        $WhatIf
    )

    $Project = Get-GitlabProject $ProjectId
    if (-not $Branch)
    {
        $Branch = $Project.DefaultBranch
    }

    $Body = @{
        branch         = $Branch
        content        = $Content
        commit_message = $CommitMessage
    }

    if ($SkipCi)
    {
        $Body.commit_message += "`n[skip ci]"
    }

    if (Invoke-GitlabApi POST "projects/$($Project.Id)/repository/files/$($FilePath | ConvertTo-UrlEncoded)" -Body $Body -SiteUrl $SiteUrl -WhatIf:$WhatIf)
    {
        Write-Host "Created $FilePath in $($Project.Name) ($Branch)"
    }
}
