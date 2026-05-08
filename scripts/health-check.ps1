# health-check.ps1 — Verify the LiteLLM proxy is running and providers are reachable
# Run while the proxy is active: .\scripts\health-check.ps1

$proxyUrl   = "http://localhost:4000"
$masterKey  = $env:LITELLM_MASTER_KEY

# If master key is not set in the environment, try loading .env
if (-not $masterKey) {
    $envFile = Join-Path (Split-Path $PSScriptRoot -Parent) ".env"
    if (Test-Path $envFile) {
        Get-Content $envFile | ForEach-Object {
            if ($_ -match "^\s*LITELLM_MASTER_KEY=(.+)$") {
                $masterKey = $matches[1].Trim()
            }
        }
    }
}

$headers = @{ Authorization = "Bearer $masterKey" }

Write-Host "`n[health-check] Checking proxy at $proxyUrl ...`n" -ForegroundColor Cyan

# 1. Basic reachability — is the server up at all?
try {
    $ping = Invoke-RestMethod -Uri "$proxyUrl/health/liveliness" -TimeoutSec 5
    Write-Host "  Proxy status : UP" -ForegroundColor Green
} catch {
    Write-Host "  Proxy status : UNREACHABLE" -ForegroundColor Red
    Write-Host "  Is the proxy running? Start it with: .\scripts\start.ps1" -ForegroundColor Yellow
    exit 1
}

# 2. Provider health — which upstream APIs are actually reachable?
# /health checks each configured model by sending a small test request
Write-Host "  Checking providers (this may take a few seconds)...`n"

try {
    $health = Invoke-RestMethod `
        -Uri "$proxyUrl/health" `
        -Headers $headers `
        -TimeoutSec 30

    # Healthy models
    if ($health.healthy_endpoints) {
        Write-Host "  Healthy providers:" -ForegroundColor Green
        foreach ($ep in $health.healthy_endpoints) {
            Write-Host "    OK  $($ep.model_name)" -ForegroundColor Green
        }
    }

    # Unhealthy models (wrong key, quota exceeded, etc.)
    if ($health.unhealthy_endpoints) {
        Write-Host ""
        Write-Host "  Unhealthy providers:" -ForegroundColor Red
        foreach ($ep in $health.unhealthy_endpoints) {
            Write-Host "    FAIL  $($ep.model_name) — $($ep.error_message)" -ForegroundColor Red
        }
    }

} catch {
    Write-Host "  Could not retrieve provider health: $_" -ForegroundColor Yellow
    Write-Host "  (This may be normal if no master key is set)" -ForegroundColor Gray
}

# 3. List available models
try {
    $models = Invoke-RestMethod `
        -Uri "$proxyUrl/v1/models" `
        -Headers $headers `
        -TimeoutSec 5

    $modelNames = $models.data | ForEach-Object { $_.id }
    Write-Host "`n  Available models: $($modelNames -join ', ')" -ForegroundColor Cyan
} catch {
    Write-Host "`n  Could not retrieve model list." -ForegroundColor Gray
}

Write-Host "`n[health-check] Done. Dashboard: $proxyUrl/ui`n" -ForegroundColor Cyan
