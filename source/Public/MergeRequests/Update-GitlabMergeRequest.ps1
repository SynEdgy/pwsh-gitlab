
function Update-GitlabMergeRequest
{
    [CmdletBinding(DefaultParameterSetName = "Update")]
    param
    (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]
        $ProjectId,

        [Parameter(Position = 1, Mandatory = $true)]
        [string]
        $MergeRequestId,

        [Parameter()]
        [string]
        $Title,

        [Parameter()]
        [string]
        $Description,

        [Parameter(ParameterSetName = "Close")]
        [switch]
        $Close,

        [Parameter(ParameterSetName = "Reopen")]
        [switch]
        $Reopen,

        [Parameter()]
        [string]
        $SiteUrl,

        [Parameter()]
        [switch]
        $WhatIf
    )

    $ProjectId = $(Get-GitlabProject -ProjectId $ProjectId).Id
    $Query = @{}

    if ($Close)
    {
        $Query['state_event'] = 'close'
    }

    if ($Reopen)
    {
        $Query['state_event'] = 'reopen'
    }

    if ($Title)
    {
        $Query['title'] = $Title
    }

    if ($Description)
    {
        $Query['description'] = $Description
    }

    Invoke-GitlabApi -HttpMethod 'PUT' -Path "projects/$ProjectId/merge_requests/$MergeRequestId" -Query $Query -SiteUrl $SiteUrl -WhatIf:$WhatIf | New-WrapperObject 'Gitlab.MergeRequest'
}
