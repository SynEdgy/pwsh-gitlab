
# https://docs.gitlab.com/ee/api/group_level_variables.html#update-variable
function Set-GitlabGroupVariable
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]
        $GroupId,

        [Parameter(Mandatory = $true, Position = 1)]
        [string]
        $Key,

        [Parameter(Mandatory = $true, Position = 2)]
        [string]
        $Value,

        [bool]
        [Parameter()]
        $Protect = $false,

        [bool]
        [Parameter()]
        $Mask = $false,

        [Parameter()]
        [string]
        $SiteUrl,

        [switch]
        [Parameter(Mandatory=$false)]
        $WhatIf
    )

    $GroupId = $GroupId | ConvertTo-UrlEncoded

    $Query = @{
        value = $Value
    }

    if ($Protect)
    {
        $Query['protected'] = 'true'
    }
    else
    {
        $Query['protected'] = 'false'
    }

    if ($Mask)
    {
        $Query['masked'] = 'true'
    }
    else
    {
        $Query['masked'] = 'false'
    }

    try
    {
        $null = Get-GitlabGroupVariable $GroupId $Key
        $IsExistingVariable = $True
    }
    catch
    {
        $IsExistingVariable = $False
    }

    if ($IsExistingVariable)
    {
        Invoke-GitlabApi PUT "groups/$GroupId/variables/$Key" -Query $Query -SiteUrl $SiteUrl -WhatIf:$WhatIf | New-WrapperObject 'Gitlab.Variable'
    }
    else
    {
        $Query.Add('key', $Key)
        Invoke-GitlabApi POST "groups/$GroupId/variables" -Query $Query -SiteUrl $SiteUrl -WhatIf:$WhatIf | New-WrapperObject 'Gitlab.Variable'
    }
}
