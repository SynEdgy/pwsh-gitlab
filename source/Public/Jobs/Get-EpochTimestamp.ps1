
function Get-EpochTimestamp
{
    [CmdletBinding()]
    [OutputType([int])]
    param
    (
        #
    )

    [int] $(New-TimeSpan -Start $(Get-Date "01/01/1970") -End $(Get-Date)).TotalSeconds
}
