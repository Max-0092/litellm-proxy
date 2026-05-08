# claude-deepseek.ps1 — Start Claude Code routed through LiteLLM → DeepSeek
# Run from anywhere: & "C:\Users\Jelmer\Tools\litellm\scripts\claude-deepseek.ps1"
#
# Requires the LiteLLM proxy to be running first:
#   .\scripts\start.ps1

$env:ANTHROPIC_BASE_URL = "http://localhost:4000"
$env:ANTHROPIC_API_KEY = "dummy"

Write-Host "[deepseek] Claude Code → LiteLLM → DeepSeek" -ForegroundColor Cyan
Write-Host "[deepseek] Make sure the proxy is running (.\scripts\start.ps1)`n" -ForegroundColor Cyan

& "C:\Users\Jelmer\Tools\node.js\claude.cmd"
