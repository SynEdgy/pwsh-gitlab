
# https://docs.gitlab.com/ee/api/project_level_variables.html#update-variable

function Set-GitlabProjectVariable
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        [Parameter()]
        [string]
        $ProjectId = '.',

        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]
        $Key,

        [Parameter(Mandatory = $true, Position = 1, ValueFromPipelineByPropertyName = $true)]
        [string]
        $Value,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [switch]
        $Protect,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [switch]
        $Mask,

        [Parameter()]
        [string]
        $SiteUrl
    )

    $Query = @{
        value = $Value
    }

    if ($Protect)
    {
        $Query.protected = 'true'
    }

    if ($Mask)
    {
        $Query.masked = 'true'
    }

    $ProjectId = $(Get-GitlabProject $ProjectId).Id

    try
    {
        $null = Get-GitlabProjectVariable -ProjectId $ProjectId -Key $Key
        $IsExistingVariable = $true
    }
    catch
    {
        $IsExistingVariable = $false
    }

    if ($PSCmdlet.ShouldProcess($ProjectId, "set $($IsExistingVariable ? 'existing' : 'new') project variable to '$Value'"))
    {
        if ($IsExistingVariable)
        {
            Invoke-GitlabApi -HttpMethod 'PUT' -Path "projects/$($ProjectId)/variables/$Key" -Query $Query -SiteUrl $SiteUrl -WhatIf:$WhatIfPreference | New-WrapperObject 'Gitlab.Variable'
        }
        else
        {
            $Query.key = $Key
            Invoke-GitlabApi -HttpMethod 'POST' -Path "projects/$($ProjectId)/variables" -Query $Query -SiteUrl $SiteUrl -WhatIf:$WhatIfPreference | New-WrapperObject 'Gitlab.Variable'
        }
    }
}
