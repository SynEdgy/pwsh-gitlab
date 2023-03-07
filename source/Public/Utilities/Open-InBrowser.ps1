
function Open-InBrowser
{
    [CmdletBinding()]
    [Alias('go')]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        $InputObject
    )

    Process
    {
        if (-not $InputObject)
        {
            # do nothing
        }
        elseif ($InputObject -is [string])
        {
            Start-Process $InputObject
        }
        elseif ($InputObject.Url -and $InputObject.Url -is [string])
        {
            Start-Process $InputObject.Url
        }
        elseif ($InputObject.WebUrl -and $InputObject.WebUrl -is [string])
        {
            Start-Process $InputObject.WebUrl
        }
    }
}
