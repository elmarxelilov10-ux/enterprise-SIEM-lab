# ==============================================================================
# Script: open-splunk-port.ps1
# Description: Automates the Windows Firewall configuration for Splunk Syslog
# ==============================================================================

Write-Host "Opening UDP Port 514 for Splunk Syslog Ingestion..." -ForegroundColor Cyan

New-NetFirewallRule -DisplayName "Splunk UDP 514" `
                    -Direction Inbound `
                    -LocalPort 514 `
                    -Protocol UDP `
                    -Action Allow `
                    -Description "Allows incoming Cisco network logs to reach Splunk"

Write-Host "Firewall rule successfully created." -ForegroundColor Green