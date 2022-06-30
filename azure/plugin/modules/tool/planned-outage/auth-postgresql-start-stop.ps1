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

#GET https://management.azure.com/subscriptions/ffffffff-ffff-ffff-ffff-ffffffffffff/resourceGroups/testrg/providers/Microsoft.DBForPostgreSql/flexibleServers/pgtestsvc1?api-version=2020-02-14-preview
$dbserverInfoRestUri='https://management.azure.com/subscriptions/' + $subscriptionId + '/resourceGroups/' `
    + $resourceGroupName + '/providers/Microsoft.DBForPostgreSql/flexibleServers/' `
    + $resourceName + '?api-version=2021-06-01'

$dbserverInfoResponse = Invoke-RestMethod -Uri $dbserverInfoRestUri -Method GET -Headers $authHeader

Write-Output "database status is " + $dbserverInfoResponse.properties.state | timestamp

if((($action -eq 'start') -And ($dbserverInfoResponse.properties.state -eq 'Stopped')) -Or (($action -eq 'stop') -And !($dbserverInfoResponse.properties.state -eq 'Stopped')))
{
    # POST https://management.azure.com/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.DBForPostgreSql/flexibleServers/{serverName}/stop?api-version=2020-02-14-preview
    # Invoke the REST API
    $restUri='https://management.azure.com/subscriptions/' + $subscriptionid + '/resourceGroups/' `
        + $resourcegroupname + '/providers/Microsoft.DBForPostgreSql/flexibleServers/' `
        + $resourcename + '/'+ $action + '?api-version=2021-06-01'
    $response = Invoke-RestMethod -Uri $restUri -Method POST -Headers $authHeader
}

Write-Output "Script finished." | timestamp