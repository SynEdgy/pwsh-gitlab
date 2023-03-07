
# https://docs.gitlab.com/ee/api/protected_branches.html#protect-repository-branches

function Protect-GitlabBranch
{
    [CmdletBinding(SupportsShouldProcess)]
    param
    (
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $ProjectId = '.',

        [Parameter(Position = 0, Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('Name')]
        [string]
        $Branch,

        [Parameter()]
        [ProtectedBranchAccessLevel]
        $PushAccessLevel,

        [Parameter()]
        [ProtectedBranchAccessLevel]
        $MergeAccessLevel,

        [Parameter()]
        [ValidateSet('developer','maintainer','admin')]
        [ProtectedBranchAccessLevel]
        $UnprotectAccessLevel,

        [Parameter()]
        [ValidateSet($null, 'true', 'false')]
        [object] #TODO: Nullable bool?
        $AllowForcePush = 'false',

        [Parameter()]
        [array] #TODO: array of what?
        $AllowedToPush,

        [Parameter()]
        [array] #TODO: array of what?
        $AllowedToMerge,

        [Parameter()]
        [array] #TODO: array of what?
        $AllowedToUnprotect,

        [Parameter()]
        [ValidateSet($null, 'true', 'false')]
        [object] #TODO: Nullable bool?
        $CodeOwnerApprovalRequired = $false,

        [Parameter()]
        [string]
        $SiteUrl
    )

    $Project = Get-GitlabProject -ProjectId $ProjectId

    $Request = @{
        name = $Branch
        push_access_level = [int]$PushAccessLevel
        merge_access_level = [int]$MergeAccessLevel
        unprotect_access_level = [int]$UnprotectAccessLevel
        allow_force_push = $AllowForcePush
        allowed_to_push = @($AllowedToPush | ConvertTo-SnakeCase)
        allowed_to_merge = @($AllowedToMerge | ConvertTo-SnakeCase)
        allowed_to_unprotect = @($AllowedToUnprotect | ConvertTo-SnakeCase)
        code_owner_approval_required = $CodeOwnerApprovalRequired
    }

    if ($PSCmdlet.ShouldProcess("$($Project.PathWithNamespace)/branches/$Branch", "protect branch $($Request | ConvertTo-Json)"))
    {
        Invoke-GitlabApi POST "projects/$($Project.Id)/protected_branches" -Body $Request | New-WrapperObject 'Gitlab.ProtectedBranch'
    }
}
