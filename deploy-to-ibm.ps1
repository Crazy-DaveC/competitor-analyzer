# IBM Cloud Deployment Script
# Run this in a NEW PowerShell window after installing IBM Cloud CLI

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "IBM Cloud Deployment Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if ibmcloud is available
try {
    $version = ibmcloud --version
    Write-Host "IBM Cloud CLI found: $version" -ForegroundColor Green
} catch {
    Write-Host "ERROR: IBM Cloud CLI not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please:" -ForegroundColor Yellow
    Write-Host "1. Close this PowerShell window" -ForegroundColor White
    Write-Host "2. Open a NEW PowerShell window" -ForegroundColor White
    Write-Host "3. Run this script again" -ForegroundColor White
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""

# Step 1: Check and install Cloud Foundry plugin
Write-Host "Step 1: Checking Cloud Foundry plugin..." -ForegroundColor Green
$cfInstalled = ibmcloud plugin list 2>&1 | Select-String "cloud-foundry"

if (-not $cfInstalled) {
    Write-Host "Installing Cloud Foundry plugin..." -ForegroundColor Yellow
    Write-Host "This may take a minute..." -ForegroundColor Cyan
    
    # Try to install from the correct repository
    $installResult = ibmcloud plugin install cloud-foundry -r "IBM Cloud" -f 2>&1
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Red
        Write-Host "Cloud Foundry Plugin Installation Failed" -ForegroundColor Red
        Write-Host "========================================" -ForegroundColor Red
        Write-Host ""
        Write-Host "IBM Cloud has deprecated Cloud Foundry." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Alternative deployment options:" -ForegroundColor Cyan
        Write-Host "1. Use IBM Code Engine (recommended)" -ForegroundColor White
        Write-Host "2. Use IBM Cloud Kubernetes Service" -ForegroundColor White
        Write-Host "3. Deploy to Vercel (easiest): vercel deploy" -ForegroundColor White
        Write-Host ""
        Read-Host "Press Enter to exit"
        exit 1
    }
    Write-Host "Cloud Foundry plugin installed successfully" -ForegroundColor Green
} else {
    Write-Host "Cloud Foundry plugin already installed" -ForegroundColor Green
}

Write-Host ""

# Step 2: Set API endpoint
Write-Host "Step 2: Setting IBM Cloud API endpoint..." -ForegroundColor Green
ibmcloud api https://cloud.ibm.com
Write-Host ""

# Step 3: Check login status
Write-Host "Step 3: Checking IBM Cloud login status..." -ForegroundColor Green
$loginCheck = ibmcloud account show 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Not logged in. Please login..." -ForegroundColor Yellow
    ibmcloud login --sso
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Login failed" -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }
} else {
    Write-Host "Already logged in" -ForegroundColor Green
}

Write-Host ""

# Step 4: Target Cloud Foundry
Write-Host "Step 4: Targeting Cloud Foundry organization and space..." -ForegroundColor Green
ibmcloud target --cf-api https://api.us-south.cf.cloud.ibm.com
if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "Failed to target Cloud Foundry" -ForegroundColor Red
    Write-Host ""
    Write-Host "This might mean:" -ForegroundColor Yellow
    Write-Host "1. Cloud Foundry is not available in your account" -ForegroundColor White
    Write-Host "2. You need to select an organization and space" -ForegroundColor White
    Write-Host ""
    Write-Host "Try running manually:" -ForegroundColor Cyan
    Write-Host "ibmcloud target --cf" -ForegroundColor White
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""

# Step 5: Set environment variables
Write-Host "Step 5: Setting environment variables..." -ForegroundColor Green
Write-Host "Reading from .env.local..." -ForegroundColor Cyan

# Read environment variables from .env.local
if (Test-Path ".env.local") {
    $envContent = Get-Content ".env.local"
    $apiKey = ($envContent | Select-String "WATSONX_API_KEY=(.+)").Matches.Groups[1].Value
    $spaceId = ($envContent | Select-String "WATSONX_SPACE_ID=(.+)").Matches.Groups[1].Value
    $url = ($envContent | Select-String "WATSONX_URL=(.+)").Matches.Groups[1].Value
    
    if ($apiKey -and $spaceId) {
        Write-Host "Setting WATSONX_API_KEY..." -ForegroundColor Cyan
        ibmcloud cf set-env competitor-analyzer-ibm WATSONX_API_KEY "$apiKey"
        
        Write-Host "Setting WATSONX_SPACE_ID..." -ForegroundColor Cyan
        ibmcloud cf set-env competitor-analyzer-ibm WATSONX_SPACE_ID "$spaceId"
        
        Write-Host "Setting WATSONX_URL..." -ForegroundColor Cyan
        ibmcloud cf set-env competitor-analyzer-ibm WATSONX_URL "$url"
        
        Write-Host "Environment variables set successfully" -ForegroundColor Green
    } else {
        Write-Host "Warning: Could not read credentials from .env.local" -ForegroundColor Yellow
    }
} else {
    Write-Host "Warning: .env.local not found" -ForegroundColor Yellow
}

Write-Host ""

# Step 6: Deploy application
Write-Host "Step 6: Deploying application to IBM Cloud..." -ForegroundColor Green
Write-Host "This will take 2-5 minutes..." -ForegroundColor Yellow
Write-Host ""

try {
    ibmcloud cf push
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Deployment Successful!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Your app is now running on IBM Cloud!" -ForegroundColor Green
    Write-Host ""
    Write-Host "To view your app:" -ForegroundColor Yellow
    Write-Host "1. Check the 'routes' in the output above" -ForegroundColor White
    Write-Host "2. Open that URL in your browser" -ForegroundColor White
    Write-Host ""
    Write-Host "To view logs:" -ForegroundColor Yellow
    Write-Host "ibmcloud cf logs competitor-analyzer-ibm --recent" -ForegroundColor White
    Write-Host ""
} catch {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "Deployment Failed" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "To troubleshoot:" -ForegroundColor Yellow
    Write-Host "1. Check logs: ibmcloud cf logs competitor-analyzer-ibm --recent" -ForegroundColor White
    Write-Host "2. Verify environment variables are set" -ForegroundColor White
    Write-Host "3. Check manifest.yml is correct" -ForegroundColor White
    Write-Host ""
}

Read-Host "Press Enter to exit"

# Made with Bob
