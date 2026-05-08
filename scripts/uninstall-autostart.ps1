# uninstall-autostart.ps1 — Remove the LiteLLM proxy startup task

$taskName = "LiteLLM-Proxy"

if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
    Write-Host "[litellm-proxy] Autostart task '$taskName' removed." -ForegroundColor Yellow
} else {
    Write-Host "[litellm-proxy] Task '$taskName' not found — nothing to remove." -ForegroundColor Gray
}
