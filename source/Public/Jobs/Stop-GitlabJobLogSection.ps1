
<#
.SYNOPSIS
Closes out a previously declared collapsible section in Gitlab CI output

.DESCRIPTION
Long description

.EXAMPLE
Start-GitlabJobLogSection "Doing the thing"
try {
    #the things
}
finally {
    Stop-GitlabJobLogSection
}

.NOTES
for reference: https://docs.gitlab.com/ce/ci/jobs/index.html#custom-collapsible-sections
#>
function Stop-GitlabJobLogSection
{
    [CmdletBinding()]
    param
    (
        #
    )

    if ($GitlabJobLogSections.Count -eq 0)
    {
        # explicitly do nothing
        # most likely case is if stop is called more than start
        return
    }

    $PreviousId = $GitlabJobLogSections.Pop()
    $Timestamp = Get-EpochTimestamp
    Write-Information -InformationAction 'Continue' -MessageData "section_end:$($Timestamp):$PreviousId`r`e[0K"
}
