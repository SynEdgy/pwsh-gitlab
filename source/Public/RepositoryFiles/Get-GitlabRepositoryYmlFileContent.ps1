
function Get-GitlabRepositoryYmlFileContent
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [string]
        $ProjectId = '.',

        [Parameter(Position = 0, Mandatory = $true)]
        [string]
        $FilePath,

        [Parameter()]
        [Alias("Branch")]
        [string]
        $Ref,

        [Parameter()]
        [string]
        $SiteUrl
    )

    $Yml = Get-GitlabRepositoryFileContent -ProjectId $ProjectId -Ref $Ref -FilePath $FilePath -SiteUrl $SiteUrl
    $Hash = $([YamlDotNet.Serialization.Deserializer].GetMethods() |
        Where-Object { $_.Name -eq 'Deserialize' -and $_.ReturnType.Name -eq 'T' -and $_.GetParameters().ParameterType.Name -eq 'String' }). `
        MakeGenericMethod(
            [object]). `
        Invoke($(New-Object 'YamlDotNet.Serialization.Deserializer'), $Yml)

    return $Hash | ConvertTo-Json -Depth 100 | ConvertFrom-Json # the JSON "double-tap" coerces HashTables into PSCustomObject (including nested children)
}
