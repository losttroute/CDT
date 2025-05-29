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

try {
    # Get the latest release
    $headers = @{
        "User-Agent" = "CDT AutoUpdater"
    }
    Write-Host "Checking for latest release..." -ForegroundColor Cyan
    $latestRelease = Invoke-RestMethod -Uri $ReleasesUrl -Headers $headers

    # Find the .exe asset
    $exeAsset = $latestRelease.assets | Where-Object { $_.name -like "CDT*.exe" } | Select-Object -First 1

    if (-not $exeAsset) {
        Write-Host "No executable found in latest release." -ForegroundColor Red
        exit 1
    }

    # Download the new version with a unique temp filename
    $tempPath = [System.IO.Path]::GetTempPath()
    $tempExe = Join-Path $tempPath ("CDT_Update_" + [guid]::NewGuid().ToString() + ".exe")

    Write-Host "Downloading new version: $($exeAsset.name)..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $exeAsset.browser_download_url -OutFile $tempExe -Headers $headers
    
    # Determine the current executable path
    $currentPath = [System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName
    
    Write-Host "Replacing current version at: $currentPath" -ForegroundColor Cyan
    
    # Close the main CDT process if running
    $processName = [System.IO.Path]::GetFileNameWithoutExtension($currentPath)
    Get-Process -Name $processName -ErrorAction SilentlyContinue | Stop-Process -Force
    
    # Wait for process to exit
    $maxRetries = 5
    $retryCount = 0
    $success = $false
    
    while ($retryCount -lt $maxRetries -and -not $success) {
        try {
            Start-Sleep -Seconds 1
            if (Test-Path $currentPath) {
                Remove-Item -Path $currentPath -Force -ErrorAction Stop
            }
            Move-Item -Path $tempExe -Destination $currentPath -Force
            $success = $true
        } catch {
            $retryCount++
            $errorMessage = $_.Exception.Message
            Write-Host "Retry $retryCount of $maxRetries: $errorMessage" -ForegroundColor Yellow
            if ($retryCount -ge $maxRetries) {
                throw $_
            }
        }
    }
    
    if ($success) {
        Write-Host "Update completed successfully. Restarting application..." -ForegroundColor Green
        
        # Restart the application
        Start-Process -FilePath $currentPath -Verb RunAs
        exit 0
    }
} catch {
    Write-Host "Update failed: $_" -ForegroundColor Red
    # Clean up temp file if it exists
    if ($tempExe -and (Test-Path $tempExe)) {
        Remove-Item -Path $tempExe -Force -ErrorAction SilentlyContinue
    }
    exit 1
}
