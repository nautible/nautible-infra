# Envrionment parameters
param(
[parameter(Mandatory=$true)] 
[string] $subscriptionid
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

# get all service bus
#https://management.azure.com/subscriptions/{subscriptionId}/providers/Microsoft.ServiceBus/namespaces?api-version=2021-11-01
$serviceBusInfoRestUri='https://management.azure.com/subscriptions/' + $subscriptionid + '/providers/Microsoft.ServiceBus/namespaces?api-version=2021-11-01'
$ServiceBusInfoResponse = Invoke-RestMethod -Uri $serviceBusInfoRestUri -Method GET -Headers $authHeader

$ServiceBusInfoResponse.value | ForEach-Object{
	$idsplit = $_.id.split('/')
	$subscriptions = $idsplit[2]
	$resourceGroups = $idsplit[4]
	$namespaces = $idsplit[8]

	# Invoke the REST API
	# DELETE https://management.azure.com/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.ServiceBus/namespaces/{namespaceName}?api-version=2021-11-01
	$restUri='https://management.azure.com/subscriptions/' + $subscriptions + '/resourceGroups/' `
        + $resourceGroups + '/providers/Microsoft.ServiceBus/namespaces/' `
        + $namespaces + '/?api-version=2021-11-01'
    $deleteMsg = 'DELETE ' + $restUri
	Write-Output $deleteMsg | timestamp 
    $response = Invoke-RestMethod -Uri $restUri -Method DELETE -Headers $authHeader

}

Write-Output "Script finished." | timestamp