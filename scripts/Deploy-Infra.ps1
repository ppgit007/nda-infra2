[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [ValidateSet("dev", "qa")]
    [string]$Environment = "dev",

    [Parameter(Mandatory = $false)]
    [ValidateSet("plan", "apply", "destroy")]
    [string]$Action = "plan",

    [Parameter(Mandatory = $false)]
    [string]$VarFile,

    [Parameter(Mandatory = $false)]
    [string]$SubscriptionId,

    [Parameter(Mandatory = $false)]
    [switch]$UseLocalState,

    [Parameter(Mandatory = $false)]
    [switch]$BootstrapBackend,

    [Parameter(Mandatory = $false)]
    [switch]$AutoApprove,

    [Parameter(Mandatory = $false)]
    [string[]]$Modules,

    [Parameter(Mandatory = $false)]
    [switch]$PromptForModules
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Assert-CommandExists {
    param(
        [Parameter(Mandatory = $true)]
        [string]$CommandName,

        [Parameter(Mandatory = $true)]
        [string]$InstallHint
    )

    if (-not (Get-Command $CommandName -ErrorAction SilentlyContinue)) {
        throw "Required command '$CommandName' is not available. $InstallHint"
    }
}

function Invoke-Terraform {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    $display = $Arguments -join " "
    Write-Host "terraform $display" -ForegroundColor DarkGray
    & terraform @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "Terraform command failed: terraform $display"
    }
}

function Test-AzureLogin {
    & az account show --query id -o tsv 2>$null | Out-Null
    return ($LASTEXITCODE -eq 0)
}

function Get-AvailableModules {
    param(
        [Parameter(Mandatory = $true)]
        [string]$MainTfPath
    )

    if (-not (Test-Path $MainTfPath)) {
        throw "Terraform file not found for module discovery: $MainTfPath"
    }

    $content = Get-Content -Path $MainTfPath -Raw
    $matches = [regex]::Matches($content, '(?m)^\s*module\s+"([^"]+)"\s*\{')

    $discovered = @()
    foreach ($match in $matches) {
        $discovered += $match.Groups[1].Value
    }

    return @($discovered | Sort-Object -Unique)
}

function Resolve-SelectedModules {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$AvailableModules,

        [Parameter(Mandatory = $false)]
        [string[]]$RequestedModules,

        [Parameter(Mandatory = $false)]
        [switch]$Interactive
    )

    if (-not $AvailableModules -or $AvailableModules.Count -eq 0) {
        throw "No Terraform modules were discovered in main.tf."
    }

    if ($RequestedModules -and $RequestedModules.Count -gt 0) {
        $normalizedRequested = @($RequestedModules | ForEach-Object { $_.Trim() } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -Unique)
        $invalid = @($normalizedRequested | Where-Object { $_ -notin $AvailableModules })

        if ($invalid.Count -gt 0) {
            throw "Invalid module name(s): $($invalid -join ', '). Available modules: $($AvailableModules -join ', ')"
        }

        return $normalizedRequested
    }

    if (-not $Interactive) {
        return @()
    }

    Write-Host "Available modules for '$Environment':" -ForegroundColor Cyan
    for ($i = 0; $i -lt $AvailableModules.Count; $i++) {
        Write-Host "[$($i + 1)] $($AvailableModules[$i])"
    }

    $selection = Read-Host "Enter module names or numbers separated by comma. Press Enter or type 'all' to deploy everything"
    if ([string]::IsNullOrWhiteSpace($selection) -or $selection.Trim().ToLowerInvariant() -eq "all") {
        return @()
    }

    $tokens = @($selection -split "," | ForEach-Object { $_.Trim() } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    $resolved = New-Object System.Collections.Generic.List[string]

    foreach ($token in $tokens) {
        if ($token -match '^\d+$') {
            $position = [int]$token
            if ($position -lt 1 -or $position -gt $AvailableModules.Count) {
                throw "Module selection index out of range: $position"
            }

            $resolved.Add($AvailableModules[$position - 1])
            continue
        }

        if ($token -in $AvailableModules) {
            $resolved.Add($token)
            continue
        }

        throw "Invalid module selection: '$token'. Use module names or list indexes from the prompt."
    }

    return @($resolved | Select-Object -Unique)
}

Assert-CommandExists -CommandName "terraform" -InstallHint "Install Terraform and add it to PATH."
Assert-CommandExists -CommandName "az" -InstallHint "Install Azure CLI and add it to PATH."

if (-not (Test-AzureLogin)) {
    throw "Azure CLI is not logged in. Run 'az login' and rerun this script."
}

if ($SubscriptionId) {
    Write-Host "Setting Azure subscription: $SubscriptionId" -ForegroundColor Cyan
    & az account set --subscription $SubscriptionId
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to set Azure subscription to '$SubscriptionId'."
    }
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$infraRoot = (Resolve-Path (Join-Path $scriptDir "..")).Path
$environmentDir = Join-Path $infraRoot "environments\$Environment"
$mainTfPath = Join-Path $environmentDir "main.tf"

if (-not (Test-Path $environmentDir)) {
    throw "Environment folder not found: $environmentDir"
}

if (-not $VarFile) {
    $VarFile = "terraform-$Environment.tfvars"
}

$varFilePath = Join-Path $environmentDir $VarFile
if (-not (Test-Path $varFilePath)) {
    throw "Var-file not found: $varFilePath"
}

$availableModules = Get-AvailableModules -MainTfPath $mainTfPath
$selectedModules = Resolve-SelectedModules -AvailableModules $availableModules -RequestedModules $Modules -Interactive:$PromptForModules

$targetArgs = @()
if ($selectedModules.Count -gt 0) {
    foreach ($moduleName in $selectedModules) {
        $targetArgs += "-target=module.$moduleName"
    }

    Write-Host "Deploying selected modules only: $($selectedModules -join ', ')" -ForegroundColor Yellow
    Write-Host "Note: Terraform -target is intended for partial operations and may leave state drift if used repeatedly." -ForegroundColor Yellow
}
else {
    Write-Host "Deploying full stack (all modules in main.tf)." -ForegroundColor Yellow
}

if ($BootstrapBackend -and -not $UseLocalState) {
    $bootstrapScript = Join-Path $scriptDir "bootstrap-$Environment-backend.ps1"
    if (-not (Test-Path $bootstrapScript)) {
        throw "Backend bootstrap script not found: $bootstrapScript"
    }

    Write-Host "Bootstrapping backend for '$Environment'..." -ForegroundColor Cyan
    & powershell -NoProfile -ExecutionPolicy Bypass -File $bootstrapScript
    if ($LASTEXITCODE -ne 0) {
        throw "Backend bootstrap failed."
    }
}

$planFile = "tfplan-$Environment.out"

Push-Location $environmentDir
try {
    Write-Host "Running in: $environmentDir" -ForegroundColor Cyan

    if ($UseLocalState) {
        Write-Host "Initializing Terraform with local state (backend disabled)." -ForegroundColor Yellow
        Invoke-Terraform -Arguments @("init", "-reconfigure", "-backend=false")
    }
    else {
        Write-Host "Initializing Terraform with configured backend." -ForegroundColor Yellow
        Invoke-Terraform -Arguments @("init", "-reconfigure")
    }

    Invoke-Terraform -Arguments @("validate")

    switch ($Action) {
        "plan" {
            $planArgs = @(
                "plan",
                "-var-file=$VarFile",
                "-out=$planFile"
            )
            $planArgs += $targetArgs

            Invoke-Terraform -Arguments $planArgs

            Write-Host "Plan saved to $planFile" -ForegroundColor Green
        }

        "apply" {
            $planArgs = @(
                "plan",
                "-var-file=$VarFile",
                "-out=$planFile"
            )
            $planArgs += $targetArgs

            Invoke-Terraform -Arguments $planArgs

            $applyArgs = @("apply")
            if ($AutoApprove) {
                $applyArgs += "-auto-approve"
            }
            $applyArgs += $planFile

            Invoke-Terraform -Arguments $applyArgs
        }

        "destroy" {
            $destroyArgs = @(
                "destroy",
                "-var-file=$VarFile"
            )
            $destroyArgs += $targetArgs

            if ($AutoApprove) {
                $destroyArgs += "-auto-approve"
            }

            Invoke-Terraform -Arguments $destroyArgs
        }
    }

    Write-Host "Terraform '$Action' completed for environment '$Environment'." -ForegroundColor Green
}
finally {
    Pop-Location
}