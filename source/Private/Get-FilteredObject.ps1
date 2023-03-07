
function Get-FilteredObject
{
    param
    (
        [Parameter(ValueFromPipeline = $true, Mandatory = $true)]
        $InputObject,

        [Parameter(Position=0)]
        [string]
        $Select = '*'
    )

    Process
    {
        foreach ($Object in $InputObject)
        {
            if (($Select -eq '*') -or (-not $Select))
            {
                $Object
            }
            elseif ($Select.Contains(','))
            {
                $Object | Select-Object $($Select -split ',')
            }
            else
            {
                $Object | Select-Object -ExpandProperty $Select
            }
        }
    }
}
