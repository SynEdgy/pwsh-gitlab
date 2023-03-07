
#TODO: singlar function

function Test-IsConfigurationEnvironmentVariables {
    [CmdletBinding()]
    param
    (
        #
    )

    Write-Debug -Message 'Returning the value of $env:GITLAB_ACCESS_TOKEN'
    $env:GITLAB_ACCESS_TOKEN
}
