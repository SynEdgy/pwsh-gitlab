function Get-PossibleGroupName
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]
        $Path,

        [Parameter(Position = 1)]
        [uint]
        $Depth = 1
    )

    $Split = $(Get-Location).Path -split '/'
    $($Split | Select-Object -Last $Depth) -join '/'
}
