# Envrionment parameters
param(
[parameter(Mandatory=$true)] 
[string] $subscriptionid,

[parameter(Mandatory=$true)] 
[string] $resourcegroupname,

[parameter(Mandatory=$true)] 
[string] $resourcename,

[parameter(Mandatory=$true)] 
[string] $action
) 
 
filter timestamp {"[$(Get-Date -Format G)]: $_"} 

Write-Output "Script started." | timestamp

# $VerbosePreference = "Continue" ##enable this for verbose logging
$ErrorActionPreference = "Stop" 

# Authenticate with Azure Automation Run As account (service principal) 
$connectionName = "AzureRunAsConnection"
#$connectionName = "AzureRunAsCertificate"

try
{
    # Get the connection "AzureRunAsConnection"
    $servicePrincipalConnection = Get-AutomationConnection -Name $connectionName

    Write-Output "Logging in to Azure..."
    Add-AzAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint | Out-Null 
}
catch {
    if (!$servicePrincipalConnection)
    {
        $ErrorMessage = "Connection $connectionName not found."
        throw $ErrorMessage
    } else{
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}
Write-Output "Authenticated with Automation Run As Account."  | timestamp 

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

#https://management.azure.com/subscriptions/subid1/resourceGroups/rg1/providers/Microsoft.ContainerService/managedClusters/clustername1?api-version=2021-03-01
$clustorInfoRestUri='https://management.azure.com/subscriptions/' + $subscriptionId + '/resourceGroups/' `
    + $resourceGroupName + '/providers/Microsoft.ContainerService/managedClusters/' `
    + $resourceName + '?api-version=2021-03-01'

$clustorInfoResponse = Invoke-RestMethod -Uri $clustorInfoRestUri -Method GET -Headers $authHeader

if((($action -eq 'start') -And ($clustorInfoResponse.properties.powerState.code -eq 'Stopped')) -Or (($action -eq 'stop') -And !($clustorInfoResponse.properties.powerState.code -eq 'Stopped')))
{
    # Invoke the REST API
    $restUri='https://management.azure.com/subscriptions/' + $subscriptionid + '/resourceGroups/' `
        + $resourcegroupname + '/providers/Microsoft.ContainerService/managedClusters/' `
        + $resourcename + '/'+ $action + '?api-version=2020-09-01'
    $response = Invoke-RestMethod -Uri $restUri -Method POST -Headers $authHeader
}

Write-Output "Script finished." | timestamp