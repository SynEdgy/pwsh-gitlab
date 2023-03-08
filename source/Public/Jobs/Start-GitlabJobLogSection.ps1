
<#
.SYNOPSIS
Produces a section that can be collapsed in the Gitlab CI output

.PARAMETER HeaderText
Name of the section

.PARAMETER Collapsed
Whether or not the section is pre-collapsed. Not currently supported. Has no affect

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
function Start-GitlabJobLogSection
{
    param
    (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]
        $HeaderText,

        [Parameter()]
        [switch]
        $Collapsed
    )

    $Timestamp = Get-EpochTimestamp
    $CollapsedHeader = ''
    if ($Collapsed)
    {
        $CollapsedHeader = '[collapsed=true]'
    }

    # use timestamp as the section name (since we are hiding that in our API)
    $SectionId = "$([System.Guid]::NewGuid().ToString("N"))"
    #TODO: Remove the Write host below
    Write-Information -InformationAction 'Continue' -MessageData "`e[0Ksection_start:$($Timestamp):$($SectionId)$($CollapsedHeader)`r`e[0K$HeaderText"
    $GitlabJobLogSections.Push($SectionId)
}
