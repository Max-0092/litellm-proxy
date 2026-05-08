# install-autostart.ps1 — Register LiteLLM proxy as a startup task
# Run once: .\scripts\install-autostart.ps1
# To remove the task later: .\scripts\uninstall-autostart.ps1

$ErrorActionPreference = "Stop"

$taskName  = "LiteLLM-Proxy"
$repoRoot  = Split-Path $PSScriptRoot -Parent
$startScript = Join-Path $repoRoot "scripts\start.ps1"
$uvPath    = (Get-Command uv -ErrorAction Stop).Source

# The task runs: powershell.exe -WindowStyle Hidden -File .\scripts\start.ps1
$action = New-ScheduledTaskAction `
    -Execute "powershell.exe" `
    -Argument "-WindowStyle Hidden -NonInteractive -File `"$startScript`"" `
    -WorkingDirectory $repoRoot

# Trigger: run at logon for the current user only (no admin needed)
$trigger = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME

# Run with the current user's permissions
$principal = New-ScheduledTaskPrincipal `
    -UserId $env:USERNAME `
    -LogonType Interactive `
    -RunLevel Limited          # Limited = no elevation, respects no-admin constraint

$settings = New-ScheduledTaskSettingsSet `
    -ExecutionTimeLimit (New-TimeSpan -Hours 0) `   # 0 = no time limit
    -RestartCount 3 `
    -RestartInterval (New-TimeSpan -Minutes 1)

# Register (or overwrite if it already exists)
Register-ScheduledTask `
    -TaskName $taskName `
    -Action $action `
    -Trigger $trigger `
    -Principal $principal `
    -Settings $settings `
    -Description "Starts the local LiteLLM proxy on http://localhost:4000" `
    -Force | Out-Null

Write-Host "[litellm-proxy] Autostart task '$taskName' registered." -ForegroundColor Green
Write-Host "  The proxy will start automatically when you log in." -ForegroundColor Green
Write-Host "  To start it now without rebooting, run: .\scripts\start.ps1" -ForegroundColor Cyan
