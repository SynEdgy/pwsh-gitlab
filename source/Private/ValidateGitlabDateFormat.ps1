
function ValidateGitlabDateFormat
{
    param
    (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]
        $DateString
    )

    if ($DateString -match "\d\d\d\d-\d\d-\d\d")
    {
        $true
    }
    else
    {
        throw "$DateString is invalid. The date format expected is YYYY-MM-DD"
    }
}
