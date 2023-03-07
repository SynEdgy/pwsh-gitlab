
function Get-EpochTimestamp
{
    [CmdletBinding()]
    param
    (
        #
    )

    [int] $(New-TimeSpan -Start $(Get-Date "01/01/1970") -End $(Get-Date)).TotalSeconds
}
