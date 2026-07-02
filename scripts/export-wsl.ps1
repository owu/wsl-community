<#
.SYNOPSIS
    Export specified WSL distributions to tar files with timestamp.
.DESCRIPTION
    Reads the distro list from $DistroNames and exports each one
    to $ExportDir with a filename like DistroName_20260702_143022.tar
#>

# ========== Configuration ==========
# List of WSL distribution names to export. Leave empty to skip export.
$DistroNames = @(
       # "Ubuntu-22.04"
       "Debian"
)

# Target directory for exported tar files.
$ExportDir = "D:\WSL-Exports"
# ===================================

# Get current timestamp for filename
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

function Export-Distro {
    param(
        [string]$DistroName,
        [string]$OutputDir,
        [string]$Timestamp
    )

    $safeName = $DistroName -replace '[<>:"/\\|?*]', '_'
    $tarFile = Join-Path $OutputDir "${safeName}_${Timestamp}.tar.gz"

    Write-Host "Exporting: $DistroName -> $tarFile" -ForegroundColor Green

    & wsl.exe --export $DistroName $tarFile

    if ($LASTEXITCODE -eq 0) {
        $size = (Get-Item $tarFile).Length / 1GB
        Write-Host "  Done ($([math]::Round($size, 2)) GB)" -ForegroundColor Green
    } else {
        Write-Host "  Failed! (Exit code: $LASTEXITCODE)" -ForegroundColor Red
    }
}

# --- Main ---

if ($DistroNames.Count -eq 0) {
    Write-Host "DistroNames is empty, nothing to export. Exiting." -ForegroundColor Yellow
    exit 0
}

# Ensure export directory exists
if (-not (Test-Path $ExportDir)) {
    New-Item -ItemType Directory -Path $ExportDir -Force | Out-Null
    Write-Host "Created export directory: $ExportDir" -ForegroundColor Cyan
}

# Shutdown all WSL instances before export
Write-Host "Stopping all WSL distributions..." -ForegroundColor Yellow
& wsl.exe --shutdown
Start-Sleep -Seconds 2

Write-Host "Starting export at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Cyan
Write-Host "Export directory: $ExportDir" -ForegroundColor Cyan
Write-Host ""

foreach ($distro in $DistroNames) {
    Write-Host "----------------------------------------" -ForegroundColor Cyan
    Export-Distro -DistroName $distro -OutputDir $ExportDir -Timestamp $Timestamp
}

Write-Host "`nExport completed at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')!" -ForegroundColor Cyan
Write-Host "Files saved to: $ExportDir" -ForegroundColor Cyan