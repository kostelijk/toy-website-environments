# Set Variables
$githubOrganizationName = 'kostelijk'
$githubRepositoryName = 'toy-website-environments'

# Create workload identity for test and associate it with GitHub repo
$testApplicationRegistration = New-AzADApplication -DisplayName 'toy-website-environments-test'
New-AzADAppFederatedCredential `
   -Name 'toy-website-environments-test' `
   -ApplicationObjectId $testApplicationRegistration.Id `
   -Issuer 'https://token.actions.githubusercontent.com' `
   -Audience 'api://AzureADTokenExchange' `
   -Subject "repo:$($githubOrganizationName)/$($githubRepositoryName):environment:Test"
New-AzADAppFederatedCredential `
   -Name 'toy-website-environments-test-branch' `
   -ApplicationObjectId $testApplicationRegistration.Id `
   -Issuer 'https://token.actions.githubusercontent.com' `
   -Audience 'api://AzureADTokenExchange' `
   -Subject "repo:$($githubOrganizationName)/$($githubRepositoryName):ref:refs/heads/main"

# Create workload identity for production and associate it with Github repo
$productionApplicationRegistration = New-AzADApplication -DisplayName 'toy-website-environments-production'
New-AzADAppFederatedCredential `
   -Name 'toy-website-environments-production' `
   -ApplicationObjectId $productionApplicationRegistration.Id `
   -Issuer 'https://token.actions.githubusercontent.com' `
   -Audience 'api://AzureADTokenExchange' `
   -Subject "repo:$($githubOrganizationName)/$($githubRepositoryName):environment:Production"
New-AzADAppFederatedCredential `
   -Name 'toy-website-environments-production-branch' `
   -ApplicationObjectId $productionApplicationRegistration.Id `
   -Issuer 'https://token.actions.githubusercontent.com' `
   -Audience 'api://AzureADTokenExchange' `
   -Subject "repo:$($githubOrganizationName)/$($githubRepositoryName):ref:refs/heads/main"

# Create resource group for test and grant Contributor permissions to workload identity
$testResourceGroup = New-AzResourceGroup -Name ToyWebsiteTest -Location westeurope

New-AzADServicePrincipal -AppId $($testApplicationRegistration.AppId)
New-AzRoleAssignment `
   -ApplicationId $($testApplicationRegistration.AppId) `
   -RoleDefinitionName Contributor `
   -Scope $($testResourceGroup.ResourceId)

# Create resource group for production and grant Contributor permissions to workload identity
$productionResourceGroup = New-AzResourceGroup -Name ToyWebsiteProduction -Location westus3

New-AzADServicePrincipal -AppId $($productionApplicationRegistration.AppId)
New-AzRoleAssignment `
   -ApplicationId $($productionApplicationRegistration.AppId) `
   -RoleDefinitionName Contributor `
   -Scope $($productionResourceGroup.ResourceId)

# Output GitHub secrets. Create secrets in GitHub portal: Settings/secrets/actions
$azureContext = Get-AzContext
Write-Host "AZURE_CLIENT_ID_TEST: $($testApplicationRegistration.AppId)"
Write-Host "AZURE_CLIENT_ID_PRODUCTION: $($productionApplicationRegistration.AppId)"
Write-Host "AZURE_TENANT_ID: $($azureContext.Tenant.Id)"
Write-Host "AZURE_SUBSCRIPTION_ID: $($azureContext.Subscription.Id)"