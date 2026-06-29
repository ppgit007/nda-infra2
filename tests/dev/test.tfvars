# Dedicated test values for Terraform integration tests
# Copy this to a new file when you want to run tests against a disposable environment.

tenant_id           = "00000000-0000-0000-0000-000000000000"
container_app_image = "mcr.microsoft.com/azuredocs/aci-helloworld:latest"
static_web_app_name = "nursedenial-test-swa"
container_app_name  = "nursedenial-test-ca"
location             = "East US"
staticWebAppLocation = "East US"
resource_group_name  = "nursedenial-test-rg"
os_type              = "Linux"
sku_name             = "Y1"
