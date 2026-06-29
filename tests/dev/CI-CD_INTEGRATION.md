# Terraform Test Suite and CI/CD Pipeline Documentation

## Overview

This document describes the comprehensive test suite for the Terraform infrastructure setup in the `dev` environment and how tests integrate into the GitHub Actions CI/CD pipeline.

## Test Architecture

### Test Files Structure

```
tests/
└── dev/
    ├── main.tftest.hcl                 # Core resource creation and output validation
    ├── security.tftest.hcl              # Security best practices and compliance tests
    ├── integration.tftest.hcl           # Module integration and output propagation
    ├── input_validation.tftest.hcl      # Input variable validation and constraints
    ├── test.tfvars.example              # Example test variables
    └── README.md                        # Quick start guide
```

### Test Categories

#### 1. **main.tftest.hcl** (15 tests)
**Purpose:** Core resource creation and output validation
- ✓ Setup run with variable validation
- ✓ Managed Identity creation
- ✓ Key Vault creation and outputs
- ✓ ACR creation and outputs
- ✓ Redis creation
- ✓ Storage Account creation and outputs
- ✓ Container App Environment creation
- ✓ Container App creation and outputs
- ✓ Static Web App creation and outputs
- ✓ Service Bus creation and outputs
- ✓ Tagging compliance
- ✓ All outputs exist and are valid

#### 2. **security.tftest.hcl** (9 tests)
**Purpose:** Security best practices and compliance validation
- ✓ Managed Identity creation for Container App
- ✓ Key Vault access policies configured
- ✓ Container App uses managed identity
- ✓ ACR authentication configured
- ✓ Redis encryption enabled
- ✓ Service Bus encryption enabled
- ✓ All resources in same location (location consistency)
- ✓ Tagging compliance (required tags present)
- ✓ Proper resource naming conventions

#### 3. **integration.tftest.hcl** (13 tests)
**Purpose:** Module integration and output propagation
- ✓ Managed Identity outputs match module outputs
- ✓ Key Vault outputs match module outputs
- ✓ ACR outputs match module outputs
- ✓ Redis outputs match module outputs
- ✓ Storage Account outputs match module outputs
- ✓ Container App Environment outputs match module outputs
- ✓ Container App outputs match module outputs
- ✓ Static Web App outputs match module outputs
- ✓ Service Bus outputs match module outputs
- ✓ Container App references correct environment
- ✓ Container App uses managed identity
- ✓ Resource group reference validation
- ✓ All resources in same resource group

#### 4. **input_validation.tftest.hcl** (13 tests)
**Purpose:** Input variable validation and constraint enforcement
- ✓ Required variables validation
- ✓ Location format validation
- ✓ Azure regions validation
- ✓ Tenant ID format validation
- ✓ Container App image format validation
- ✓ Static Web App name constraints
- ✓ Container App name constraints
- ✓ Naming convention compliance
- ✓ Default values application
- ✓ Variable type validation
- ✓ Optional variables handling
- ✓ Resource naming length constraints
- ✓ Identifier formatting validation

### Total Test Coverage: 50 Tests

## Running Tests Locally

### Prerequisites

1. **Terraform:** v1.5.0 or later (with native test framework)
2. **Azure CLI:** Latest version for OIDC authentication
3. **Azure Subscription:** Access to deploy resources
4. **Service Principal:** With appropriate permissions

### One-Time Setup

```bash
cd terraform

# Create test variables file
cp tests/dev/test.tfvars.example tests/dev/test.tfvars

# Edit test.tfvars with your values
# Required:
#   - tenant_id (your Azure Tenant ID)
#   - container_app_image (registry/image:tag)
#   - static_web_app_name (globally unique)
#   - container_app_name (unique in RG)

# Login to Azure
az login
```

### Running All Tests

```bash
cd terraform

# Run all tests for dev environment
terraform test tests/dev/

# Run with verbose output for debugging
terraform test -verbose tests/dev/

# Run specific test file
terraform test tests/dev/main.tftest.hcl
terraform test tests/dev/security.tftest.hcl
terraform test tests/dev/integration.tftest.hcl
terraform test tests/dev/input_validation.tftest.hcl
```

### PowerShell Test Runner

```powershell
# Use provided PowerShell runner script
PowerShell .\tests\dev\run-tests.ps1 -Verbose

# Or manually in PowerShell
cd terraform/tests/dev
terraform test -verbose
```

## CI/CD Pipeline Integration

### GitHub Actions Workflow Sequence

#### **Terraform Plan Workflow** (`terraform-plan.yml`)

```
Checkout Code
   ↓
Setup Terraform
   ↓
Create Plugin Cache
   ↓
Auto-format Files
   ↓
Format Validation ✓
   ↓
Azure OIDC Login
   ↓
Terraform Init
   ↓
Terraform Validate ✓
   ↓
🧪 RUN TERRAFORM TESTS ← Tests BEFORE plan
   ↓
Terraform Plan
   ↓
Upload Plan Artifact
   ↓
Success/Failure
```

**Key Steps:**
- `Terraform Validate`: Syntax and schema validation
- `🧪 Terraform Tests`: Comprehensive test suite (50 tests)
- `Terraform Plan`: Generate deployment plan

**Stage Order (Critical):**
1. Format & Lint → Catch style issues
2. Validate → Catch schema errors
3. **Tests** → Catch logic errors BEFORE plan
4. Plan → Show what will be deployed

#### **Terraform Apply Workflow** (`terraform-apply.yml`)

```
Checkout Code
   ↓
Setup Terraform
   ↓
Create Plugin Cache
   ↓
Azure OIDC Login
   ↓
Terraform Init
   ↓
Terraform Validate ✓
   ↓
🧪 RUN TERRAFORM TESTS ← Tests before apply
   ↓
Download Plan from Artifact
   ↓
Terraform Apply
   ↓
Success/Failure
```

**Key Steps:**
- `Terraform Tests`: Revalidate before applying
- `Download Plan`: Use plan generated in previous workflow
- `Terraform Apply`: Execute the plan with auto-approve

### Workflow Configuration

#### Environment Variables
```yaml
TF_IN_AUTOMATION: true      # Enable automation mode
TF_INPUT: false             # Disable interactive prompts
ARM_CLIENT_ID: (GitHub Secret)
ARM_TENANT_ID: (GitHub Secret)
ARM_SUBSCRIPTION_ID: (GitHub Secret)
ARM_USE_OIDC: true          # Use OIDC for authentication
```

#### Artifact Management
- **Plan Artifacts**: Retained for 60 days
- **Naming**: `tfplan-{run_id}-{environment}`
- **Contents**: tfplan binary + plan.txt (text representation)

### Setting Up GitHub Actions

1. **Add Secrets to Repository**
   ```
   Settings → Secrets and Variables → Actions → New repository secret
   - AZURE_CLIENT_ID: Your service principal client ID
   - AZURE_TENANT_ID: Your Azure tenant ID
   - AZURE_SUBSCRIPTION_ID: Your subscription ID
   ```

2. **Trigger Workflows**
   - Plan workflow: Push to main branch
   - Apply workflow: Manual trigger after plan review

3. **Monitor Workflow Execution**
   - GitHub Actions tab → Select workflow run
   - Review test results in "Run Terraform Tests" step
   - Download artifacts if needed

## Test Best Practices

### Writing New Tests

1. **Group by Concern**
   ```hcl
   run "descriptive_test_name" {
     command = plan  # or apply
     
     assert {
       condition     = <condition_to_verify>
       error_message = "Clear description of what failed"
     }
   }
   ```

2. **Use Descriptive Names**
   - ✓ `validate_key_vault_access_policies`
   - ✗ `test1` or `kv_test`

3. **Single Responsibility**
   - Each test validates ONE behavior
   - Use multiple assertions for related conditions

4. **Clear Error Messages**
   - Include expected vs actual in message
   - Help other developers understand the failure

### Test Execution Order

- **Setup run**: Initializes test environment
- **Plan tests**: Can run without applying
- **Apply tests**: Require actual Azure resources (uses `terraform apply`)
- **Cleanup**: Automatic via `terraform test` framework

### Debugging Failed Tests

1. **Check Test Output**
   ```bash
   terraform test -verbose tests/dev/
   ```

2. **Review Module Outputs**
   ```bash
   # After running tests/dev/, check:
   # 1. Module output values
   # 2. Resource creation status
   # 3. Variable interpolation results
   ```

3. **Validate Variables**
   ```bash
   # Ensure test.tfvars has correct values:
   terraform console -var-file=test.tfvars
   ```

4. **Check Azure Permissions**
   ```bash
   az account show
   az role assignment list --assignee <principal_id>
   ```

## Test Maintenance

### Regular Review Tasks

- [ ] Review test coverage monthly
- [ ] Update tests when module changes occur
- [ ] Add tests for new resources
- [ ] Remove tests for deprecated resources
- [ ] Update error messages for clarity

### Common Issues and Fixes

| Issue | Cause | Solution |
|-------|-------|----------|
| Tests pass locally, fail in CI/CD | Missing secrets | Add repository secrets |
| Test timeout | Slow resource creation | Increase timeout (300s default) |
| Wrong variable values | Stale test.tfvars | Update test.tfvars from example |
| Module output mismatch | Module changes | Update test assertions |
| Permission errors | Service principal lacks roles | Add required role assignments |

## Performance Considerations

### Test Execution Time

- **Plan Tests:** ~10-30 seconds (no resource creation)
- **Apply Tests:** ~5-15 minutes (creates actual resources)
- **Total Suite:** ~20-30 minutes in CI/CD
- **Local Execution:** ~15-25 minutes

### Optimization Tips

1. Use `command = plan` for non-integration tests
2. Reuse resources across tests when possible
3. Clean up resources between test runs
4. Use mock providers for unit testing (if available)

## Security Considerations

### Test Variables

- **Never commit** `test.tfvars` with real values
- Use `test.tfvars.example` as template
- Rotate test service principal credentials regularly
- Use OIDC for GitHub Actions (no secrets in workflow)

### Test Isolation

- Each test run creates isolated resources
- Use unique naming for test resources
- Cleanup failures may leave dangling resources
- Monitor Azure billing for orphaned resources

## Future Enhancements

### Planned Improvements

- [ ] Add policy compliance tests
- [ ] Add cost estimation tests
- [ ] Add performance benchmarks
- [ ] Add disaster recovery tests
- [ ] Add multi-region failover tests
- [ ] Integration with Azure Compliance Manager
- [ ] Automated rollback on test failure
- [ ] Test reporting dashboard

### Advanced Testing Scenarios

```hcl
# Example: Policy compliance test
run "policy_compliance" {
  command = plan
  
  assert {
    condition     = output.key_vault_purge_protection == true
    error_message = "Key Vault must have purge protection enabled"
  }
}
```

## Troubleshooting Guide

### Common Errors and Solutions

```
Error: "attribute not found"
Solution: Check module outputs match test assertions

Error: "expected object, got string"
Solution: Verify variable types in variables.tf

Error: "resource already exists"
Solution: Cleanup test resources or use unique names

Error: "unauthorized"
Solution: Verify Azure permissions and OIDC setup
```

### Logging and Diagnostics

Enable debug logging:
```bash
TF_LOG=DEBUG terraform test tests/dev/
TF_LOG_PATH=terraform-debug.log terraform test tests/dev/
```

Review logs:
```bash
# Azure CLI diagnostics
az rest --resource-group <rg> --resource-type Microsoft.Resources/deployments

# Terraform logs
cat terraform-debug.log | grep ERROR
```

## References

- [Terraform Testing Documentation](https://developer.hashicorp.com/terraform/language/tests)
- [Azure Terraform Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [GitHub Actions Workflows](https://docs.github.com/en/actions)
- [Azure OIDC Authentication](https://learn.microsoft.com/en-us/azure/active-directory/workload-identities/workload-identity-federation)

## Support and Contribution

For issues with tests:
1. Check troubleshooting guide above
2. Review test output with `-verbose` flag
3. Consult Terraform documentation
4. Contact infrastructure team

To contribute new tests:
1. Create descriptive test in appropriate file
2. Add clear assertions and error messages
3. Run tests locally to verify
4. Document test purpose in comment
5. Submit PR for review
