
function New-WrapperObject
{
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipeline = $true)]
        [Object]
        $InputObject,

        [Parameter(Position = 0)]
        [string]
        $DisplayType
    )

    process
    {
        foreach ($item in $InputObject)
        {
            $Wrapper = New-Object PSObject
            $item.PSObject.Properties |
                Sort-Object Name |
                ForEach-Object {
                    $Wrapper | Add-Member -MemberType NoteProperty -Name $($_.Name | ConvertTo-PascalCase) -Value $_.Value
                }

            # aliases for common property names
            Add-AliasedProperty -On $Wrapper -From 'Url' -To 'WebUrl'

            if ($DisplayType)
            {
                $Wrapper.PSTypeNames.Insert(0, $DisplayType)

                $IdentityPropertyName = $GitlabIdentityPropertyNameExemptions[$DisplayType]
                if ($null -eq $IdentityPropertyName)
                {
                    $IdentityPropertyName = 'Iid' # default for anything that isn't explicitly mapped
                }

                if ($IdentityPropertyName -ne '')
                {
                    if ($Wrapper.$IdentityPropertyName)
                    {
                        $TypeShortName = $DisplayType.Split('.') | Select-Object -Last 1
                        Add-AliasedProperty -On $Wrapper -From "$($TypeShortName)Id" -To $IdentityPropertyName
                    }
                    else
                    {
                        Write-Warning -Message "$DisplayType does not have an identity field"
                    }
                }
            }

            $Wrapper
        }
    }
}
