# Envrionment parameters
param(
[parameter(Mandatory=$true)] 
[string] $subscriptionid,

[parameter(Mandatory=$true)] 
[string] $action
) 
 
filter timestamp {"[$(Get-Date -Format G)]: $_"} 

Write-Output "Script started." | timestamp

try
{
    "Logging in to Azure..."
    Connect-AzAccount -Identity
}
catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
}
Write-Output "Authenticated with Automation System ID."  | timestamp 

$startTime = Get-Date 
Write-Output "Azure Automation local time: $startTime." | timestamp 

# Get the authentication token 
$azContext = Get-AzContext
$azProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
$profileClient = New-Object -TypeName Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient -ArgumentList ($azProfile)
$token = $profileClient.AcquireAccessToken($azContext.Subscription.TenantId)
$authHeader = @{
    'Content-Type'='application/json'
    'Authorization'='Bearer ' + $token.AccessToken
}
Write-Output "Authentication Token acquired." | timestamp 

# GET https://management.azure.com/subscriptions/{subscriptionId}/providers/Microsoft.ContainerService/managedClusters?api-version=2023-04-01
$clustorInfoRestUri='https://management.azure.com/subscriptions/' + $subscriptionid + '/providers/Microsoft.ContainerService/managedClusters?api-version=2023-04-01'

$clustorInfoResponse = Invoke-RestMethod -Uri $clustorInfoRestUri -Method GET -Headers $authHeader

$clustorInfoResponse.value | ForEach-Object {
    # /subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/{resourceProviderNamespace}/{resourceType}/{resourceName}
    $idsplit = $_.id.split('/')
    $subscriptions = $idsplit[2]
    $resourceGroups = $idsplit[4]
    $resourceName = $idsplit[8]

    if((($action -eq 'start') -And ($_.properties.powerState.code -eq 'Stopped')) -Or (($action -eq 'stop') -And !($_.properties.powerState.code -eq 'Stopped')))
    {
        # Invoke the REST API
        $restUri='https://management.azure.com/subscriptions/' + $subscriptions + '/resourceGroups/' `
            + $resourceGroups + '/providers/Microsoft.ContainerService/managedClusters/' `
            + $resourceName + '/'+ $action + '?api-version=2020-09-01'
        $stopMsg = 'STOP ' + $restUri
        Write-Output $stopMsg | timestamp 
        $response = Invoke-RestMethod -Uri $restUri -Method POST -Headers $authHeader
    }

}

Write-Output "Script finished." | timestamp