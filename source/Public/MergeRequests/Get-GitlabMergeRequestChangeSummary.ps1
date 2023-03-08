
function Get-GitlabMergeRequestChangeSummary
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        $MergeRequest
    )

    $Data = Invoke-GitlabGraphQL -Query @"
    {
        project(fullPath: "$($MergeRequest.ProjectPath)") {
            mergeRequest(iid: "$($MergeRequest.MergeRequestId)") {
                diffStatsSummary {
                    additions
                    deletions
                    files: fileCount
                }
                commitsWithoutMergeCommits {
                    nodes {
                      author {
                          username
                      }
                      authoredDate
                    }
                }
                notes {
                    nodes {
                      author {
                          username
                      }
                      body
                      updatedAt
                    }
                }
            }
        }
    }
"@

    $Mr = $Data.Project.mergeRequest
    $Notes = $Mr.notes.nodes | Where-Object body -NotMatch "^assigned to @$($MergeRequest.Author.username)" # filter out self-assignment
    $Summary = [PSCustomObject]@{
        Changes           = $Mr.diffStatsSummary | New-WrapperObject
        Authors           = $Mr.commitsWithoutMergeCommits.nodes.author.username        | Select-Object -Unique | Sort-Object
        FirstCommittedAt  = $Mr.commitsWithoutMergeCommits.nodes.authoredDate           | Sort-Object | Select-Object -First 1
        ReviewRequestedAt = $Notes | Where-Object body -Match '^requested review from @' | Sort-Object updatedAt | Select-Object -First 1 -ExpandProperty updatedAt
        AssignedAt        = $Notes | Where-Object body -Match '^assigned to @' | Sort-Object updatedAt | Select-Object -First 1 -ExpandProperty updatedAt
        MarkedReadyAt     = $Notes | Where-Object body -Match '^marked this merge request as \*\*ready\*\*' | Sort-Object updatedAt | Select-Object -First 1 -ExpandProperty updatedAt
        ApprovedAt        = $Notes | Where-Object body -Match '^approved this merge request' |
                                Sort-Object updatedAt | Select-Object -First 1 -ExpandProperty updatedAt
        TimeToMerge       = '(computed below)'
    }

    $MergedAt = $MergeRequest.MergedAt
    if ($Summary.ReviewRequestedAt)
    {
        $Summary.TimeToMerge = @{
            Duration = $MergedAt - $Summary.ReviewRequestedAt
            Measure = 'FromReviewRequested'
        }
    }
    elseif ($Summary.AssignedAt)
    {
        $Summary.TimeToMerge = @{
            Duration = $MergedAt - $Summary.AssignedAt
            Measure='FromAssigned'
        }
    }
    elseif ($Summary.MarkedReadyAt)
    {
        $Summary.TimeToMerge = @{
            Duration = $MergedAt - $Summary.MarkedReadyAt
            Measure='FromMarkedReady'
        }
    }
    else
    {
        $Summary.TimeToMerge = @{
            Duration = $MergedAt - $MergeRequest.CreatedAt
            Measure='FromCreated'
        }
    }

    $Summary
}
