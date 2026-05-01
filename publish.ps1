<#
.SYNOPSIS
    Publish progress to GitHub Pages.
    Run this after clicking "Publish Progress" in the tracker.

.DESCRIPTION
    1. Reads state.json from your Downloads folder (browser download)
    2. Copies it into this repo
    3. Commits and pushes to GitHub
    4. GitHub Pages updates automatically (within ~60 seconds)
#>

$ErrorActionPreference = "Stop"
$siteDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Find the most recent state.json in Downloads
$downloads = [Environment]::GetFolderPath("UserProfile") + "\Downloads"
$stateFile = Get-ChildItem "$downloads\state*.json" -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1

if (-not $stateFile) {
    Write-Host "ERROR: No state.json found in Downloads folder." -ForegroundColor Red
    Write-Host "Click 'Publish Progress' in the tracker first, then re-run this script."
    exit 1
}

Write-Host "Found: $($stateFile.FullName)" -ForegroundColor Cyan
Write-Host "  Modified: $($stateFile.LastWriteTime)"

# Copy to site folder
Copy-Item $stateFile.FullName "$siteDir\state.json" -Force
Write-Host "Copied to: $siteDir\state.json" -ForegroundColor Green

# Git commit and push
Push-Location $siteDir
try {
    git add state.json
    $date = Get-Date -Format "yyyy-MM-dd HH:mm"
    git commit -m "Progress update $date"
    git push
    Write-Host ""
    Write-Host "Published successfully!" -ForegroundColor Green
    Write-Host "Your team will see the updated progress on the GitHub Pages URL."
} catch {
    Write-Host "Git error: $_" -ForegroundColor Red
} finally {
    Pop-Location
}
