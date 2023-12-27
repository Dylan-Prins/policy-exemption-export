# Input bindings are passed in via param block.
param($Timer)

$subscriptions = Get-AzSubscription | Where-Object {$_.State -eq 'Enabled'}

if($null -ne $subscriptions){
    Write-verbose "Subscriptions found"
    Write-debug $subscriptions
} else {
    write-verbose "No subscriptions found"
    write-Debug "No subscriptions found"
}

foreach ($sub in $subscriptions) {

    $tags = (Get-AzTag -ResourceId "/subscriptions/$($sub.id)").properties

    if ($tags.TagsProperty.keys -eq "owner") {
        [PSCustomObject]@{
            SubscriptionID = $sub.Id
            SubscriptionName = $sub.Name
            Owner = $tags.TagsProperty.Owner ? $tags.TagsProperty.Owner : $tags.TagsProperty.owner
        }
        write-output $env:AzureWebJobsStorage
        $report = Get-AzPolicyState -SubscriptionId $sub.Id | Where-Object { $_.ComplianceState -eq "NonCompliant" -and $_.PolicyDefinitionAction -eq "deployIfNotExists" } | ForEach-Object {
            [PSCustomObject]@{
                ResourceType = $_.ResourceType
                ResourceGroup = $_.ResourceGroup
                ResourceName = ($_.ResourceId -split '/')[-1]
                PolicyAssignment = $_.PolicyAssignmentName
                PolicyDefinitionReferenceId = $_.PolicyDefinitionReferenceId
            }
        }


    }
}