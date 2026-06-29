# General Configuration
location              = "eastus"      # Azure region where resources will be deployed 
staticWebAppLocation  = "eastus2"     # Static Web App requires eastus2, westus2, etc.
environment           = "qa"          # Environment name (e.g., dev, qa, prod)
subscription_shortcut = "vss"         # Subscription shortcut code for resource naming
project               = "nursedenial" # Project name for resource naming
project_shortcut      = "nda"         # Project shortcut code for resource naming
location_shortcut     = "eus"         # Location shortcut code (eus=eastus, eus2=eastus2, etc.)
component             = "mycomponent" # Component name for resource naming
owner                 = "pp@pp.com"   # Owner of the resources
resource_group_name   = "my-rg2"      # Name of the resource group (must be unique within the subscription)

# Networking (pre-existing, owned by the networking team). Replace with QA values.
existing_vnet_name           = "vss-nda-qa-eus-vnet"
function_subnet_name         = "vss-nda-qa-eus-snet-func"
private_endpoint_subnet_name = "vss-nda-qa-eus-snet-pep"

# Key Vault
tenant_id = "d026fded-54e6-40ed-82bc-cb6a408bc4ed" # Replace with your Azure Tenant ID

# Container App
# Removed: container_app_image - container apps are not used in this stack.

# Function App
# function_app_service_plan_id            = "your-service-plan-id"            # Replace with your App Service Plan ID
# function_app_storage_account_name       = "myfnappstorageaccount"           # Replace with your Storage Account Name
# function_app_storage_account_access_key = "your-storage-account-access-key" # Replace with your Storage Account Access Key

# Function App Service Plan (Flex Consumption requires FC1)
os_type  = "Linux"
sku_name = "FC1"

# Temporary deployment toggles for current subscription permissions/network constraints.
enable_function_vnet_integration         = false
create_function_storage_role_assignments = false

# API Management (APIM)
# apim_publisher_name  = "PP Publisher" # Replace with your APIM publisher name
# apim_publisher_email = "pp@pp.com"     # Replace with your APIM publisher email
# apim_sku_name        = "Developer"    # Replace with your desired APIM SKU (e.g., Developer, Basic, Standard, Premium)
# apim_sku_capacity    = 1              # Replace with the capacity for the selected SKU

# Role Assignment
#role_assignment_scope                = "/subscriptions/your-subscription-id/resourceGroups/your-resource-group" # Replace with your scope
#role_assignment_role_definition_name = "Contributor"                                                            # Replace with your desired role definition name

# Application Names
static_web_app_name = "my-static-web-app-002" # IMPORTANT: Must be globally unique across Azure
# function_app_name   = "my-function-app"       # Replace with your desired Function App name
key_vault_name = "vss-nda-qa-eus-kv01" # IMPORTANT: Must be globally unique across Azure (3-24 alphanumeric+dashes)
