<#
.SYNOPSIS
    CDT Auto-Updater Script
.DESCRIPTION
    This script handles the update process for CDT.
    It's downloaded and executed by the main application when an update is available.
.PARAMETER TargetPath
    The path to the PowerShell script that should be updated
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$TargetPath
)

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

    # Download directly from the main branch instead of releases
    $scriptUrl = "https://raw.githubusercontent.com/$RepoOwner/$RepoName/main/CDT.ps1"

    # Download the new version with a unique temp filename
    $tempPath = [System.IO.Path]::GetTempPath()
    $tempScript = Join-Path $tempPath ("CDT_Update_" + [guid]::NewGuid().ToString() + ".ps1")

    Write-Host "Downloading new version from main branch..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $scriptUrl -OutFile $tempScript -Headers $headers

    # Use the provided target path
    $currentPath = $TargetPath

    Write-Host "Replacing current version at: $currentPath" -ForegroundColor Cyan
    
    # Close any PowerShell processes running this script
    $processes = Get-Process -Name "powershell" -ErrorAction SilentlyContinue | 
                 Where-Object { $_.MainWindowTitle -like "*CDT*" }
    
    if ($processes) {
        $processes | Stop-Process -Force
        Start-Sleep -Seconds 2
    }
    
    # Wait for process to exit and replace the file
    $maxRetries = 5
    $retryCount = 0
    $success = $false
    
    while ($retryCount -lt $maxRetries -and -not $success) {
        try {
            Start-Sleep -Seconds 1
            if (Test-Path $currentPath) {
                Remove-Item -Path $currentPath -Force -ErrorAction Stop
            }
            Move-Item -Path $tempScript -Destination $currentPath -Force
            $success = $true
        } catch {
            $retryCount++
            $errorMessage = $_.Exception.Message
            Write-Host "Retry ${retryCount} of ${maxRetries}: $errorMessage" -ForegroundColor Yellow
            if ($retryCount -ge $maxRetries) {
                throw $_
            }
        }
    }
    
    if ($success) {
        Write-Host "Update completed successfully. Restarting application..." -ForegroundColor Green
        
        # Restart the application
        Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$currentPath`"" -Verb RunAs
        exit 0
    }
} catch {
    Write-Host "Update failed: $_" -ForegroundColor Red
    # Clean up temp file if it exists
    if ($tempScript -and (Test-Path $tempScript)) {
        Remove-Item -Path $tempScript -Force -ErrorAction SilentlyContinue
    }
    exit 1
}
