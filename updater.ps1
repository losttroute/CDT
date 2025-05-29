<#
.SYNOPSIS
    CDT Auto-Updater Script
.DESCRIPTION
    This script handles the update process for CDT.
    It's downloaded and executed by the main application when an update is available.
.PARAMETER TargetPath
    The path to the PowerShell script or EXE that should be updated
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

    # Determine if we're updating a PS1 or EXE
    $isExe = $TargetPath.EndsWith('.exe', 'CurrentCultureIgnoreCase')
    
    # Download URL based on file type
    if ($isExe) {
        $asset = $latestRelease.assets | Where-Object { $_.name -like "*.exe" } | Select-Object -First 1
        if (-not $asset) {
            throw "No EXE release asset found"
        }
        $downloadUrl = $asset.browser_download_url
    } else {
        $downloadUrl = "https://raw.githubusercontent.com/$RepoOwner/$RepoName/main/CDT.ps1"
    }

    # Download the new version with a unique temp filename
    $tempPath = [System.IO.Path]::GetTempPath()
    $tempFile = Join-Path $tempPath ("CDT_Update_" + [guid]::NewGuid().ToString() + (if ($isExe) { ".exe" } else { ".ps1" }))

    Write-Host "Downloading new version..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $downloadUrl -OutFile $tempFile -Headers $headers

    # Close any running instances
    if ($isExe) {
        # For EXE - close all instances of our EXE
        $processName = [System.IO.Path]::GetFileNameWithoutExtension($TargetPath)
        $processes = Get-Process -Name $processName -ErrorAction SilentlyContinue
    } else {
        # For PS1 - close PowerShell windows with CDT in title
        $processes = Get-Process -Name "powershell" -ErrorAction SilentlyContinue | 
                     Where-Object { $_.MainWindowTitle -like "*CDT*" }
    }
    
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
            if (Test-Path $TargetPath) {
                Remove-Item -Path $TargetPath -Force -ErrorAction Stop
            }
            Move-Item -Path $tempFile -Destination $TargetPath -Force
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
        if ($isExe) {
            Start-Process -FilePath $TargetPath -Verb RunAs
        } else {
            Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$TargetPath`"" -Verb RunAs
        }
        exit 0
    }
} catch {
    Write-Host "Update failed: $_" -ForegroundColor Red
    # Clean up temp file if it exists
    if ($tempFile -and (Test-Path $tempFile)) {
        Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue
    }
    exit 1
}
