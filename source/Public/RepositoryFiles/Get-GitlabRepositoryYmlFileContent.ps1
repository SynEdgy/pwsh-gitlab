
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

    $yml = Get-GitlabRepositoryFileContent -ProjectId $ProjectId -Ref $Ref -FilePath $FilePath -SiteUrl $SiteUrl
    $hash = ConvertFrom-Yaml -Yaml $yml -AllDocuments -Ordered

    return $hash | ConvertTo-Json -Depth 100 | ConvertFrom-Json # the JSON "double-tap" coerces HashTables into PSCustomObject (including nested children)
}
