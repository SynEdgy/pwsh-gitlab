
function Invoke-GitlabApi
{
    param
    (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]
        $HttpMethod,

        [Parameter(Position = 1, Mandatory = $true)]
        [string]
        $Path,

        [Parameter(Position = 2)]
        [hashtable]
        $Query = @{},

        [Parameter()]
        [hashtable]
        $Body = @{},

        [Parameter()]
        [uint]
        $MaxPages = 1,

        [Parameter()]
        [string]
        $Api = 'v4',

        [Parameter()]
        [string]
        $SiteUrl,

        [Parameter()]
        [switch]
        $WhatIf
    )

    if ($MaxPages -gt [int]::MaxValue)
    {
         $MaxPages = [int]::MaxValue
    }

    if ($SiteUrl)
    {
        Write-Debug "Attempting to resolve site using $SiteUrl"
        $Site = Get-GitlabConfiguration | Select-Object -ExpandProperty Sites | Where-Object Url -eq $SiteUrl
    }

    if (-not $Site)
    {
        Write-Debug "Attempting to resolve site using local git context"
        $Site = Get-GitlabConfiguration | Select-Object -ExpandProperty Sites | Where-Object Url -eq $(Get-LocalGitContext).Site
    }

    if (-not $Site -or $Site -is [array])
    {
        $Site = Get-DefaultGitlabSite
        Write-Debug "Using default site ($($Site.Url))"
    }

    $GitlabUrl = $Site.Url
    $AccessToken = $Site.AccessToken

    $Headers = @{
        'Accept' = 'application/json'
    }

    if ($AccessToken)
    {
        $Headers['Authorization'] = "Bearer $AccessToken"
    }
    else
    {
        throw "GitlabCli: environment not configured`nSee https://github.com/chris-peterson/pwsh-gitlab#getting-started for details"
    }

    if (-not $GitlabUrl.StartsWith('http'))
    {
        $GitlabUrl = "https://$GitlabUrl"
    }

    $SerializedQuery = ''
    $Delimiter = '?'
    if($Query.Count -gt 0)
    {
        foreach($Name in $Query.Keys)
        {
            $Value = $Query[$Name]
            if ($Value)
            {
                $SerializedQuery += $Delimiter
                $SerializedQuery += "$Name="
                $SerializedQuery += [System.Net.WebUtility]::UrlEncode($Value)
                $Delimiter = '&'
            }
        }
    }

    $Uri = "$GitlabUrl/api/$Api/$Path$SerializedQuery"

    $RestMethodParams = @{}
    if($MaxPages -gt 1)
    {
        $RestMethodParams.FollowRelLink = $true
        $RestMethodParams.MaximumFollowRelLink = $MaxPages
    }

    if ($Body.Count -gt 0)
    {
        $RestMethodParams.ContentType = 'application/json'
        $RestMethodParams.Body        = $Body | ConvertTo-Json
    }

    if($WhatIf)
    {
        $SerializedParams = ""
        if($RestMethodParams.Count -gt 0)
        {
            $SerializedParams = $RestMethodParams.Keys |
                ForEach-Object {
                    "-$_ `"$($RestMethodParams[$_])`""
                } |
                Join-String -Separator " "
            $SerializedParams += " "
        }

        Write-Host "WhatIf: $HttpMethod $Uri $SerializedParams"
    }
    else
    {
        Write-Debug -Message "$HttpMethod $Uri"
        $Result = Invoke-RestMethod -Method $HttpMethod -Uri $Uri -Header $Headers @RestMethodParams
        if($MaxPages -gt 1)
        {
            # Unwrap pagination container
            $Result | ForEach-Object {
                $_
            }
        }
        else
        {
            $Result
        }
    }
}
