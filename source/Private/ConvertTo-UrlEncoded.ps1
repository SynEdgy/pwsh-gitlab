
function ConvertTo-UrlEncoded
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Position = 0, ValueFromPipeline = $true)]
        [string]
        $Value
    )

    [System.Net.WebUtility]::UrlEncode($Value)
}
