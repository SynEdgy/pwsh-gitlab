
function Add-AliasedProperty
{
    param
    (
        [Parameter(Mandatory = $true, Position = 0)]
        [PSCustomObject]
        $On,

        [Parameter(Mandatory = $true)]
        [string]
        $From,

        [Parameter(Mandatory = $true)]
        [string]
        $To
    )

    if ($null -ne $On.$To -and -not (Get-Member -Name $On.$To -InputObject $On))
    {
        $On | Add-Member -MemberType 'NoteProperty' -Name $From -Value $On.$To
    }
}
