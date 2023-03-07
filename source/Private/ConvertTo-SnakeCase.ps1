
function ConvertTo-SnakeCase
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position=0, ValueFromPipeline=$true)]
        $InputObject
    )

    Process
    {
        foreach ($Value in $InputObject)
        {
            if ($Value -is [string])
            {
                return [regex]::replace($Value, '(?<=.)(?=[A-Z])', '_').ToLower()
            }

            if ($Value -is [hashtable])
            {
                $Value.Keys.Clone() | ForEach-Object {
                    $OriginalValue = $Value[$_]
                    $Value.Remove($_)
                    $Value[$($_ | ConvertTo-SnakeCase)] = $OriginalValue
                }

                $Value
            }
        }
    }
}
