
function New-GitlabPipeline
{
    [CmdletBinding()]
    [Alias("build")]
    param
    (
        [Parameter()]
        [string]
        $ProjectId = '.',

        [Parameter()]
        [Alias("Branch")]
        [string]
        $Ref = '.',

        [Parameter()]
        [switch]
        $Wait,

        [Parameter()]
        [switch]
        $Follow,

        [Parameter()]
        [string]
        $SiteUrl,

        [Parameter()]
        [switch]
        $WhatIf
    )

    $Project = Get-GitlabProject -ProjectId $ProjectId
    $ProjectId = $Project.Id

    if ($Ref)
    {
        if ($Ref -eq '.')
        {
            $Ref = $(Get-LocalGitContext).Branch
        }
    }
    else
    {
        $Ref = $Project.DefaultBranch
    }

    $GitlabApiArguments = @{
        HttpMethod = "POST"
        Path       = "projects/$ProjectId/pipeline"
        Query      = @{
            'ref' = $Ref
        }
        SiteUrl    = $SiteUrl
    }

    $Pipeline = Invoke-GitlabApi @GitlabApiArguments -WhatIf:$WhatIf | New-WrapperObject 'Gitlab.Pipeline'

    if ($Wait)
    {
        Write-Information -InformationAction 'Continue' -MessageData "$($Pipeline.Id) created..."
        while ($True) #TODO: Set a timeout or something
        {
            Start-Sleep -Seconds 5
            $Jobs = $Pipeline | Get-GitlabJob -IncludeTrace |
                Where-Object { $_.Status -ne 'manual' -and $_.Status -ne 'skipped' -and $_.Status -ne 'created' } |
                Sort-Object CreatedAt

            if ($Jobs)
            {
                Clear-Host
                Write-Information "$($Pipeline.WebUrl)"
                Write-Information -InformationAction 'Continue' -MessageData ''
                $Jobs |
                    Where-Object { $_.Status -eq 'success' } |
                        ForEach-Object {
                            Write-Information -InformationAction 'Continue' -MessageData "[$($_.Name)] ✅" -ForegroundColor DarkGreen
                        }
                $Jobs |
                    Where-Object { $_.Status -eq 'failed' } |
                        ForEach-Object {
                            Write-Information -InformationAction 'Continue' -MessageData "[$($_.Name)] ❌" -ForegroundColor DarkRed
                    }

                Write-Information -InformationAction 'Continue' -MessageData '' #Remove
                $InProgress = $Jobs |
                    Where-Object { $_.Status -ne 'success' -and $_.Status -ne 'failed' }
                if ($InProgress)
                {
                    $InProgress |
                        ForEach-Object {
                            Write-Information -InformationAction 'Continue' -MessageData "[$($_.Name)] ⏳" -ForegroundColor DarkYellow
                            $RecentProgress = $_.Trace -split "`n" | Select-Object -Last 15
                            $RecentProgress | ForEach-Object {
                                Write-Information -InformationAction 'Continue' -MessageData "  $_"
                        }
                    }
                }
                else
                {
                    break
                }
            }
        }
    }

    if ($Follow)
    {
        Start-Process $Pipeline.WebUrl
    }
    else
    {
        $Pipeline
    }
}
