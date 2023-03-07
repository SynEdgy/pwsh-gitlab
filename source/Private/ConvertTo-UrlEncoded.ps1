
function ConvertTo-UrlEncoded {
    [CmdletBinding()]
    param
    (
        [Parameter(Position=0, ValueFromPipeline = $true)]
        [string]
        $Value
    )

    [System.Net.WebUtility]::UrlEncode($Value)
}
