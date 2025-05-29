<#
.SYNOPSIS
    CDT Auto-Updater 
.DESCRIPTION
    This executable handles the update process for CDT.
    It's called by the main application when an update is available.
.PARAMETER TargetPath
    The path to the executable that should be updated
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$TargetPath
)

#region Initialization
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

# GitHub repository information
$RepoOwner = "losttroute"
$RepoName = "CDT"
$ReleasesUrl = "https://api.github.com/repos/$RepoOwner/$RepoName/releases/latest"

# Console colors
$Host.UI.RawUI.BackgroundColor = "Black"
$Host.UI.RawUI.ForegroundColor = "White"
Clear-Host

function Write-Status {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] " -NoNewline
    Write-Host $Message -ForegroundColor $Color
}

try {
    # Show updater header
    Write-Host "=== CDT Updater ===" -ForegroundColor Cyan
    Write-Host "Starting update process..." -ForegroundColor White
    Write-Host ""
    
    # Get the latest release
    Write-Status "Checking for latest release..." -Color Cyan
    $headers = @{ "User-Agent" = "CDT AutoUpdater" }
    $latestRelease = Invoke-RestMethod -Uri $ReleasesUrl -Headers $headers

    # Find the EXE asset in the release
    $asset = $latestRelease.assets | Where-Object { $_.name -like "CDT*.zip" } | Select-Object -First 1
    if (-not $asset) {
        throw "No ZIP release asset found containing CDT.exe"
    }
    
    $downloadUrl = $asset.browser_download_url
    $latestVersion = $latestRelease.tag_name

    # Download the new version
    $tempPath = [System.IO.Path]::GetTempPath()
    $tempZip = Join-Path $tempPath "CDT_Update_$([guid]::NewGuid().ToString()).zip"
    
    Write-Status "Downloading version $latestVersion..." -Color Cyan
    Invoke-WebRequest -Uri $downloadUrl -OutFile $tempZip -Headers $headers

    # Extract the ZIP
    $extractPath = Join-Path $tempPath "CDT_Extract_$([guid]::NewGuid().ToString())"
    New-Item -ItemType Directory -Path $extractPath | Out-Null
    
    Write-Status "Extracting files..." -Color Cyan
    Expand-Archive -Path $tempZip -DestinationPath $extractPath -Force

    # Find the CDT.exe in the extracted files
    $newExePath = Get-ChildItem -Path $extractPath -Recurse -Filter "CDT.exe" | Select-Object -First 1 -ExpandProperty FullName
    if (-not $newExePath) {
        throw "Could not find CDT.exe in the downloaded package"
    }

    # Close any running instances of CDT.exe
    Write-Status "Closing running instances..." -Color Cyan
    $processName = [System.IO.Path]::GetFileNameWithoutExtension($TargetPath)
    $processes = Get-Process -Name $processName -ErrorAction SilentlyContinue
    
    if ($processes) {
        $processes | Stop-Process -Force
        Start-Sleep -Seconds 2
    }

    # Replace the file
    $maxRetries = 5
    $retryCount = 0
    $success = $false
    
    Write-Status "Updating application..." -Color Cyan
    
    while ($retryCount -lt $maxRetries -and -not $success) {
        try {
            Start-Sleep -Seconds 1
            if (Test-Path $TargetPath) {
                Remove-Item -Path $TargetPath -Force -ErrorAction Stop
            }
            Copy-Item -Path $newExePath -Destination $TargetPath -Force
            $success = $true
        } catch {
            $retryCount++
            $errorMessage = $_.Exception.Message
            Write-Status "Retry ${retryCount} of ${maxRetries}: $errorMessage" -Color Yellow
            if ($retryCount -ge $maxRetries) {
                throw $_
            }
        }
    }
    
    if ($success) {
        # Clean up temp files
        Remove-Item -Path $tempZip -Force -ErrorAction SilentlyContinue
        Remove-Item -Path $extractPath -Recurse -Force -ErrorAction SilentlyContinue
        
        Write-Status "Update completed successfully!" -Color Green
        Write-Status "Restarting application..." -Color Cyan
        
        # Restart the application
        Start-Process -FilePath $TargetPath -Verb RunAs
    }
} catch {
    Write-Status "Update failed: $_" -Color Red
    # Clean up temp files if they exist
    if ($tempZip -and (Test-Path $tempZip)) {
        Remove-Item -Path $tempZip -Force -ErrorAction SilentlyContinue
    }
    if ($extractPath -and (Test-Path $extractPath)) {
        Remove-Item -Path $extractPath -Recurse -Force -ErrorAction SilentlyContinue
    }
    
    Write-Host "Press any key to exit..." -ForegroundColor Red
    $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | Out-Null
    exit 1
}
