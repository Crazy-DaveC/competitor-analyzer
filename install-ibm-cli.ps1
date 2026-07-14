# IBM Cloud CLI Installation Script for Windows
# Run this script in PowerShell as Administrator

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "IBM Cloud CLI Installation Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "WARNING: This script should be run as Administrator for best results." -ForegroundColor Yellow
    Write-Host "Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    Write-Host ""
    $continue = Read-Host "Continue anyway? (y/n)"
    if ($continue -ne "y") {
        exit
    }
}

# Step 1: Download IBM Cloud CLI
Write-Host "Step 1: Downloading IBM Cloud CLI..." -ForegroundColor Green
$installerUrl = "https://clis.cloud.ibm.com/download/bluemix-cli/latest/win64"
$installerPath = "$env:TEMP\IBM_Cloud_CLI.exe"

try {
    Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath
    Write-Host "Download complete" -ForegroundColor Green
} catch {
    Write-Host "Download failed: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please download manually from:" -ForegroundColor Yellow
    Write-Host "https://cloud.ibm.com/docs/cli?topic=cli-install-ibmcloud-cli" -ForegroundColor Yellow
    exit 1
}

# Step 2: Install IBM Cloud CLI
Write-Host ""
Write-Host "Step 2: Installing IBM Cloud CLI..." -ForegroundColor Green
Write-Host "The installer window will open. Follow the prompts to complete installation." -ForegroundColor Yellow
Write-Host ""

try {
    Start-Process -FilePath $installerPath -Wait
    Write-Host "Installation complete" -ForegroundColor Green
} catch {
    Write-Host "Installation failed: $_" -ForegroundColor Red
    exit 1
}

# Step 3: Verify installation
Write-Host ""
Write-Host "Step 3: Verifying IBM Cloud CLI installation..." -ForegroundColor Green

# Refresh environment variables
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

Start-Sleep -Seconds 2

try {
    $version = ibmcloud --version
    Write-Host "IBM Cloud CLI installed successfully" -ForegroundColor Green
    Write-Host "Version: $version" -ForegroundColor Cyan
} catch {
    Write-Host "IBM Cloud CLI not found in PATH" -ForegroundColor Red
    Write-Host "You may need to close and reopen PowerShell" -ForegroundColor Yellow
}

# Step 4: Install Cloud Foundry plugin
Write-Host ""
Write-Host "Step 4: Installing Cloud Foundry plugin..." -ForegroundColor Green

try {
    ibmcloud plugin install cloud-foundry -f
    Write-Host "Cloud Foundry plugin installed successfully" -ForegroundColor Green
} catch {
    Write-Host "Failed to install Cloud Foundry plugin: $_" -ForegroundColor Red
    Write-Host "You can install it manually later with: ibmcloud plugin install cloud-foundry" -ForegroundColor Yellow
}

# Step 5: Verify Cloud Foundry plugin
Write-Host ""
Write-Host "Step 5: Verifying Cloud Foundry plugin..." -ForegroundColor Green

try {
    $plugins = ibmcloud plugin list
    Write-Host "Installed plugins:" -ForegroundColor Green
    Write-Host $plugins -ForegroundColor Cyan
} catch {
    Write-Host "Could not list plugins" -ForegroundColor Red
}

# Cleanup
Write-Host ""
Write-Host "Cleaning up temporary files..." -ForegroundColor Green
Remove-Item -Path $installerPath -ErrorAction SilentlyContinue

# Summary
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Installation Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "1. Close and reopen PowerShell (or your terminal)" -ForegroundColor White
Write-Host "2. Run: ibmcloud login --sso" -ForegroundColor White
Write-Host "3. Run: ibmcloud target --cf" -ForegroundColor White
Write-Host "4. Navigate to app: cd competitor-analyzer" -ForegroundColor White
Write-Host "5. Deploy: npm run deploy:ibm" -ForegroundColor White
Write-Host ""
Write-Host "For detailed instructions, see: IBM_CLOUD_DEPLOYMENT.md" -ForegroundColor Cyan
Write-Host ""

Read-Host "Press Enter to exit"

# Made with Bob
