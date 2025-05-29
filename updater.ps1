<#
.SYNOPSIS
    CDT Auto-Updater Script
.DESCRIPTION
    This script handles the update process for CDT.
    It's downloaded and executed by the main application when an update is available.
#>

#region Initialization
#Requires -Version 5.1
#Requires -RunAsAdministrator

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

# GitHub repository information
$RepoOwner = "losttroute"
$RepoName = "CDT"
$ReleasesUrl = "https://api.github.com/repos/$RepoOwner/$RepoName/releases/latest"

# Get the latest release
$headers = @{
    "User-Agent" = "CDT AutoUpdater"
}
$latestRelease = Invoke-RestMethod -Uri $ReleasesUrl -Headers $headers

# Find the .exe asset (assuming you'll upload the compiled EXE as a release asset)
$exeAsset = $latestRelease.assets | Where-Object { $_.name -like "CDT*.exe" } | Select-Object -First 1

if (-not $exeAsset) {
    Write-Host "No executable found in latest release." -ForegroundColor Red
    exit 1
}

# Download the new version
$tempPath = [System.IO.Path]::GetTempPath()
$tempExe = Join-Path $tempPath $exeAsset.name

try {
    # Download the new version
    Invoke-WebRequest -Uri $exeAsset.browser_download_url -OutFile $tempExe -Headers $headers
    
    # Determine the current executable path
    $currentPath = [System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName
    
    # Close the current instance (this script runs in a separate process)
    # Replace the old version with the new one
    Start-Sleep -Seconds 1  # Brief delay to ensure main process has exited
    Move-Item -Path $tempExe -Destination $currentPath -Force
    
    # Restart the application
    Start-Process -FilePath $currentPath -Verb RunAs
} catch {
    Write-Host "Update failed: $_" -ForegroundColor Red
    exit 1
}

exit 0