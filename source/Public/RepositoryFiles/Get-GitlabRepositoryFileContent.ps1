
# https://docs.gitlab.com/ee/api/repository_files.html#get-file-from-repository
function Get-GitlabRepositoryFileContent
{
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipelineByPropertyName = $true)]
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

    $File = Get-GitlabRepositoryFile -ProjectId $ProjectId -FilePath $FilePath -Ref $Ref -SiteUrl $SiteUrl

    if ($File -and $File.Encoding -eq 'base64')
    {
        return [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($File.Content))
    }
}
