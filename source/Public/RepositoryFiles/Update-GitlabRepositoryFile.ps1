

# https://docs.gitlab.com/ee/api/repository_files.html#update-existing-file-in-repository

function Update-GitlabRepositoryFile
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
        [switch]
        $SkipEqualityCheck = $false,

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

    $body = @{
        branch         = $Branch
        content        = $Content
        commit_message = $CommitMessage
    }

    if ($SkipCi)
    {
        $body.commit_message += "`n[skip ci]"
    }

    if (-not $SkipEqualityCheck)
    {
        $CurrentContent = Get-GitlabRepositoryFileContent -ProjectId $Project.Id -Ref $Branch -FilePath $FilePath -SiteUrl $SiteUrl
        if ($CurrentContent -eq $Content)
        {
            Write-Information -InformationAction 'Continue' -MessageData "$FilePath contents is identical, skipping update"
            return
        }
    }

    if (Invoke-GitlabApi -HttpMethod 'PUT' -Path "projects/$($Project.Id)/repository/files/$($FilePath | ConvertTo-UrlEncoded)" -Body $body -SiteUrl $SiteUrl -WhatIf:$WhatIf)
    {
        Write-Information -InformationAction 'Continue' -MessageData "Updated $FilePath in $($Project.Name) ($Branch)"
    }
}
