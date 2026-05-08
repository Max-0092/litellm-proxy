# start.ps1 — Start the LiteLLM proxy server
# Run from the repo root: .\scripts\start.ps1

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path $PSScriptRoot -Parent

# Load .env file into environment variables
$envFile = Join-Path $repoRoot ".env"
if (Test-Path $envFile) {
    Get-Content $envFile | ForEach-Object {
        if ($_ -match "^\s*([^#][^=]+)=(.*)$") {
            [System.Environment]::SetEnvironmentVariable($matches[1].Trim(), $matches[2].Trim(), "Process")
        }
    }
    Write-Host "[litellm-proxy] Loaded environment from .env" -ForegroundColor Green
} else {
    Write-Warning ".env file not found - copy .env.example to .env and fill in your API keys"
    exit 1
}

$configFile = Join-Path $repoRoot "config.yaml"

Write-Host "[litellm-proxy] Starting on http://localhost:4000 ..." -ForegroundColor Cyan
Write-Host "[litellm-proxy] Press Ctrl+C to stop`n" -ForegroundColor Cyan

# Force UTF-8 output — prevents UnicodeEncodeError from LiteLLM's banner
# on Windows terminals that default to cp1252 encoding
$env:PYTHONUTF8 = "1"

# uv run ensures the proxy runs inside the project's virtual environment
Set-Location $repoRoot
uv run litellm --config $configFile --port 4000
