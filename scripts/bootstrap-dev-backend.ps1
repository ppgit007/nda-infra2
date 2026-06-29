# bootstrap-backend.ps1
# This script sets up a secure, isolated remote backend for Terraform state management.

# 1. Variables - Change these values to match your preferred naming
$BACKEND_RG_NAME = "rg-dev-terraform-mgmt"
$LOCATION = "eastus" # Update this to your preferred region (e.g., westeurope, centralus)
$STORAGE_ACCOUNT_NAME = "stdevtfstate2026" # MUST BE UNIQUE globally across all of Azure (lowercase + numbers only, 3-24 chars)
$CONTAINER_NAME = "tfstate"

Write-Host "=== Starting Azure Backend Bootstrap ===" -ForegroundColor Cyan

# 2. Check if logged into Azure CLI
$azCheck = az account show --query name -o tsv 2>$null
if (-not $azCheck) {
    Write-Error "You are not logged in to Azure CLI. Please run 'az login' first."
    exit
}
Write-Host "Logged in to Azure Subscription. Proceeding..." -ForegroundColor Green

# 3. Create the dedicated Management Resource Group
Write-Host "Creating Resource Group: $BACKEND_RG_NAME..." -ForegroundColor Yellow
az group create --name $BACKEND_RG_NAME --location $LOCATION -o table

# 4. Create the secure Storage Account
Write-Host "Creating Storage Account: $STORAGE_ACCOUNT_NAME..." -ForegroundColor Yellow
az storage account create `
    --name $STORAGE_ACCOUNT_NAME `
    --resource-group $BACKEND_RG_NAME `
    --location $LOCATION `
    --sku Standard_LRS `
    --encryption-services blob `
    --allow-blob-public-access false -o table

# 5. Create the Storage Container for the state file
Write-Host "Creating Storage Container: $CONTAINER_NAME..." -ForegroundColor Yellow
az storage container create `
    --name $CONTAINER_NAME `
    --account-name $STORAGE_ACCOUNT_NAME -o table

Write-Host "=== Backend Infrastructure Successfully Created! ===" -ForegroundColor Green
Write-Host "Resource Group:  $BACKEND_RG_NAME"
Write-Host "Storage Account: $STORAGE_ACCOUNT_NAME"
Write-Host "Blob Container:  $CONTAINER_NAME" -ForegroundColor Cyan
