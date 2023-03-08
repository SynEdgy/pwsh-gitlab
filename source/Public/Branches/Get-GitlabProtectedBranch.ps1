
# https://docs.gitlab.com/ee/api/protected_branches.html#list-protected-branches

function Get-GitlabProtectedBranch
{
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]
        $ProjectId = '.',

        [Parameter()]
        [string]
        $Name,

        [Parameter()]
        [string]
        $SiteUrl
    )

    $Project  = Get-GitlabProject -ProjectId $ProjectId
    $Resource = "projects/$($Project.Id)/protected_branches"

    if (-not [string]::IsNullOrWhiteSpace($Name))
    {
        $Resource += "/$Name"
    }

    try
    {
        Invoke-GitlabApi -HttpMethod 'GET' -Path $Resource -Query $Query -SiteUrl $SiteUrl
            | New-WrapperObject 'Gitlab.ProtectedBranch'
            | Add-Member -MemberType 'NoteProperty' -Name 'ProjectId' -Value $Project.Id -PassThru
    }
    catch
    {
        if ($_.Exception.Response.StatusCode.ToString() -eq 'NotFound')
        {
            Write-Information -InformationAction 'Continue' -MessageData ('Protected Branch {0} not found.' -f $Name)
        }
        else
        {
            throw
        }
    }
}
