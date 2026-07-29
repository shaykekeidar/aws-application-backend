$ErrorActionPreference = "Stop"

$terraformDirectory = Join-Path $PSScriptRoot "terraform"
$alb = terraform -chdir="$terraformDirectory" output -raw alb_dns_name

Write-Host "Testing backend through ALB: http://$alb/api/hello"

Invoke-RestMethod "http://$alb/api/hello"