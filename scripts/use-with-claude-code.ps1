# use-with-claude-code.ps1
# Routes Claude Code through the LiteLLM proxy so it uses DeepSeek instead of Anthropic.
#
# Model mapping (defined in config.yaml):
#   claude-opus-4-7         → deepseek-v4-pro  (thinking mode, budget 10k tokens)
#   claude-sonnet-4-6       → deepseek-v4-pro  (thinking mode, budget 8k tokens)
#   claude-haiku-4-5-*      → deepseek-v4-flash (fast, for agents and sub-tasks)
#
# Usage:
#   . .\scripts\use-with-claude-code.ps1           # activate proxy mode
#   . .\scripts\use-with-claude-code.ps1 --reset   # back to Anthropic directly
#
# The leading dot (.) is required — it runs the script in your current shell
# so the environment variables persist. Without the dot they vanish immediately.

param(
    [switch]$Reset
)

if ($Reset) {
    Remove-Item Env:\ANTHROPIC_BASE_URL -ErrorAction SilentlyContinue
    Remove-Item Env:\ANTHROPIC_API_KEY  -ErrorAction SilentlyContinue
    Write-Host "[claude-code] Reset — Claude Code now uses Anthropic directly." -ForegroundColor Yellow
    return
}

# Load master key from .env
$repoRoot  = Split-Path $PSScriptRoot -Parent
$masterKey = "sk-local-dev-key"

Get-Content (Join-Path $repoRoot ".env") | ForEach-Object {
    if ($_ -match "^\s*LITELLM_MASTER_KEY=(.+)$") { $masterKey = $matches[1].Trim() }
}

$env:ANTHROPIC_BASE_URL = "http://localhost:4000"
$env:ANTHROPIC_API_KEY  = $masterKey

Write-Host "[claude-code] Proxy mode active" -ForegroundColor Green
Write-Host ""
Write-Host "  Opus  + Sonnet  →  deepseek-v4-pro   (thinking mode)" -ForegroundColor Cyan
Write-Host "  Haiku + agents  →  deepseek-v4-flash  (fast)" -ForegroundColor Cyan
Write-Host ""
Write-Host "  claude --model claude-sonnet-4-6" -ForegroundColor White
Write-Host "  claude --model claude-haiku-4-5-20251001" -ForegroundColor White
Write-Host ""
Write-Host "  To reset: . .\scripts\use-with-claude-code.ps1 -Reset" -ForegroundColor Gray
