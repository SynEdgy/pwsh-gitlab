
# https://docs.gitlab.com/ee/api/topics.html#delete-a-project-topic

function Remove-GitlabTopic
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('Id')]
        [string]
        $TopicId
    )

    if ($PSCmdlet.ShouldProcess("topic $TopicId", "delete"))
    {
        if (Invoke-GitlabApi DELETE "topics/$TopicId" -SiteUrl $SiteUrl)
        {
            #TODO: Replace this write host for verbose or Debug
            Write-Host "Topic $TopicId deleted"
        }
    }
}
