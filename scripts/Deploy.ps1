[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [ValidateSet("full", "bootstrap", "plan", "apply", "destroy")]
    [string]$Mode = "full",

    [Parameter(Mandatory = $false)]
    [ValidateSet("dev", "qa")]
    [string]$Environment = "dev",

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

function Write-Stage {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    Write-Host ""
    Write-Host ("=" * 78) -ForegroundColor Cyan
    Write-Host "  $Message" -ForegroundColor Cyan
    Write-Host ("=" * 78) -ForegroundColor Cyan
}

function Invoke-OrThrow {
    param(
        [Parameter(Mandatory = $true)]
        [scriptblock]$Block,

        [Parameter(Mandatory = $true)]
        [string]$Description
    )

    & $Block
    if ($LASTEXITCODE -ne 0) {
        throw "$Description failed with exit code $LASTEXITCODE"
    }
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$deployInfraScript = Join-Path $scriptDir "Deploy-Infra.ps1"
$bootstrapScript = Join-Path $scriptDir "bootstrap-$Environment-backend.ps1"

if (-not (Test-Path $deployInfraScript)) {
    throw "Missing required script: $deployInfraScript"
}

function Get-InfraArgs {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet("plan", "apply", "destroy")]
        [string]$Action,

        [Parameter(Mandatory = $false)]
        [switch]$RunBootstrap
    )

    $args = @{
        Environment = $Environment
        Action      = $Action
    }

    if (-not [string]::IsNullOrWhiteSpace($VarFile)) {
        $args.VarFile = $VarFile
    }

    if (-not [string]::IsNullOrWhiteSpace($SubscriptionId)) {
        $args.SubscriptionId = $SubscriptionId
    }

    if ($UseLocalState) {
        $args.UseLocalState = $true
    }

    if ($RunBootstrap -and -not $UseLocalState) {
        $args.BootstrapBackend = $true
    }

    if ($AutoApprove) {
        $args.AutoApprove = $true
    }

    if ($Modules -and $Modules.Count -gt 0) {
        $args.Modules = $Modules
    }

    if ($PromptForModules) {
        $args.PromptForModules = $true
    }

    return $args
}

function Invoke-InfraStage {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet("plan", "apply", "destroy")]
        [string]$Action,

        [Parameter(Mandatory = $false)]
        [switch]$RunBootstrap
    )

    $stageName = "Stage: Terraform $Action ($Environment)"
    Write-Stage -Message $stageName

    $args = Get-InfraArgs -Action $Action -RunBootstrap:$RunBootstrap
    Invoke-OrThrow -Description "Deploy-Infra ($Action)" -Block {
        & $deployInfraScript @args
    }
}

function Invoke-BootstrapOnly {
    if ($UseLocalState) {
        throw "Mode 'bootstrap' cannot be used with -UseLocalState."
    }

    if (-not (Test-Path $bootstrapScript)) {
        throw "Backend bootstrap script not found: $bootstrapScript"
    }

    Write-Stage -Message "Stage: Backend bootstrap ($Environment)"
    Invoke-OrThrow -Description "Bootstrap backend" -Block {
        & powershell -NoProfile -ExecutionPolicy Bypass -File $bootstrapScript
    }
}

switch ($Mode) {
    "bootstrap" {
        Invoke-BootstrapOnly
    }

    "plan" {
        Invoke-InfraStage -Action "plan" -RunBootstrap:$BootstrapBackend
    }

    "apply" {
        Invoke-InfraStage -Action "apply" -RunBootstrap:$BootstrapBackend
    }

    "destroy" {
        Invoke-InfraStage -Action "destroy" -RunBootstrap:$BootstrapBackend
    }

    "full" {
        # Full mode mirrors a typical stage flow for local deployment:
        # optional backend bootstrap + plan/apply in one command.
        Invoke-InfraStage -Action "apply" -RunBootstrap:$BootstrapBackend
    }
}

Write-Host "Completed mode '$Mode' for environment '$Environment'." -ForegroundColor Green