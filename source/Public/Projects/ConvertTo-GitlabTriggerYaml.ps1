
function ConvertTo-GitlabTriggerYaml
{
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        $InputObject,

        [Parameter()]
        [ValidateSet($null, 'depend')]
        [string]
        $Strategy = $null,

        [Parameter()]
        [string]
        $StageName = 'trigger'
    )

    Begin
    {
        $Yaml = @"
stages:
  - $StageName
"@
        $Projects = @()
        if ([string]::IsNullOrWhiteSpace($Strategy))
        {
            $StrategyYaml = ''
        }
        else
        {
            $StrategyYaml = "`n    strategy: $Strategy"
        }
    }

    Process
    {
        foreach ($Object in $InputObject)
        {
            if ($Projects.Contains($Object.ProjectId))
            {
                continue
            }

            $Projects += $Object.ProjectId
            $Yaml += @"


$($Object.Name):
  stage: $StageName
  trigger:
    project: $($Object.PathWithNamespace)$StrategyYaml
"@
        }
    }

    End
    {
        $Yaml
    }
}
