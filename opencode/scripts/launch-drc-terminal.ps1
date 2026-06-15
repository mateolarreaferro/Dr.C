# Dr.C Terminal — workshop launch (Windows).
#   powershell -ExecutionPolicy Bypass -File scripts\launch-drc-terminal.ps1

$ErrorActionPreference = "Stop"
. "$PSScriptRoot\workshop-path.ps1"

$Root = Split-Path $PSScriptRoot -Parent
Set-Location $Root

$WorkDir = if ($args.Count -gt 0) { $args[0] } else { Join-Path $env:USERPROFILE "lac-workshop-demo" }
New-Item -ItemType Directory -Force -Path $WorkDir | Out-Null

if (-not (Get-Command csound -ErrorAction SilentlyContinue)) {
    Write-Host "Csound not found on PATH."
    Write-Host "Install Csound 7 from https://csound.com/download.html"
    Write-Host "See GET-STARTED.md"
    Read-Host "Press Enter to close"
    exit 1
}

if (-not (Get-Command bun -ErrorAction SilentlyContinue)) {
    Write-Host "Bun not found. Install from https://bun.sh"
    Write-Host "See GET-STARTED.md"
    Read-Host "Press Enter to close"
    exit 1
}

Write-Host "Dr.C Terminal (Csound 7)"
Write-Host "Csound: $((csound --version 2>&1 | Select-Object -First 1))"
Write-Host "Bun: $(bun --version)"
Write-Host "Work folder: $WorkDir"
Write-Host ""

if (-not (Test-Path "node_modules")) {
    Write-Host "First run: bun install"
    bun install
}

bun run dev -- $WorkDir
