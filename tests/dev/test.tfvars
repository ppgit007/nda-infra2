# Plan-only test values. No real resources are created; these just satisfy
# required variables so `terraform test` (command = plan) can run.
tenant_id                         = "00000000-0000-0000-0000-000000000000"
static_web_app_name               = "nursedenial-test-swa"
location                          = "eastus"
staticWebAppLocation              = "eastus2"
resource_group_name               = "my-rg2"
existing_vnet_resource_group_name = "my-rg1"
os_type                           = "Linux"
sku_name                          = "FC1"
