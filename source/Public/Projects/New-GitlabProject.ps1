
# https://docs.gitlab.com/ee/api/projects.html#create-project

function New-GitlabProject
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]
        $ProjectName,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Group')]
        [Alias('GroupId')]
        [string]
        $DestinationGroup,

        [Parameter(ParameterSetName = 'Personal')]
        [switch]
        $Personal,

        [Parameter()]
        [ValidateSet('private', 'internal', 'public')]
        [string]
        $Visibility = 'internal',

        [Parameter()]
        [switch]
        $CloneNow,

        [Parameter()]
        [string]
        $SiteUrl
    )

    if ($DestinationGroup)
    {
        $Group = Get-GitlabGroup -GroupId $DestinationGroup
        if(-not $Group)
        {
            throw "DestinationGroup '$DestinationGroup' not found"
        }

        $NamespaceId = $Group.Id
    }

    if ($Personal)
    {
        $NamespaceId = $null # defaults to current user
    }

    if ($PSCmdlet.ShouldProcess($NamespaceId, "create new project '$ProjectName'" ))
    {
        $Project = Invoke-GitlabApi POST "projects" @{
            name         = $ProjectName
            namespace_id = $NamespaceId
            visibility   = $Visibility
        } -SiteUrl $SiteUrl -WhatIf:$WhatIfPreference | New-WrapperObject 'Gitlab.Project'

        if ($CloneNow)
        {
            git clone $Project.SshUrlToRepo
            Set-Location $ProjectName
        }
        else
        {
            $Project
        }
    }
}
