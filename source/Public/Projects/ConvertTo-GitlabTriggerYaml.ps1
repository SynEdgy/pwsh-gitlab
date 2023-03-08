
function ConvertTo-GitlabTriggerYaml
{
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [object]
        $InputObject,

        [Parameter()]
        [ValidateSet($null, 'depend')]
        [string]
        $Strategy = $null,

        [Parameter()]
        [string]
        $StageName = 'trigger'
    )

    begin
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

    process
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

    end
    {
        $Yaml
    }
}
