# IBM Code Engine Deployment Script
# Builds from local source via IBM Container Registry, then updates the Code Engine app

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "IBM Code Engine Deployment Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Config
$projectName = "competitor-analyzer"
$appName     = "competitor-analyzer"
$buildName   = "competitor-analyzer-build"
$namespace   = "ce--0d7a9-2bt5rda2txf2"
$registry    = "us.icr.io"
$imageTag    = "latest"
$imageFull   = "$registry/$namespace/competitor-analyzer-image:$imageTag"

# Step 1: Check IBM Cloud CLI
try {
    $version = ibmcloud --version 2>&1
    Write-Host "IBM Cloud CLI found: $version" -ForegroundColor Green
} catch {
    Write-Host "ERROR: IBM Cloud CLI not found!" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""

# Step 2: Ensure required plugins are installed
Write-Host "Step 1: Checking required plugins..." -ForegroundColor Green
$plugins = ibmcloud plugin list 2>&1
if (-not ($plugins | Select-String "code-engine")) {
    Write-Host "Installing Code Engine plugin..." -ForegroundColor Yellow
    ibmcloud plugin install code-engine -f
}
if (-not ($plugins | Select-String "container-registry")) {
    Write-Host "Installing Container Registry plugin..." -ForegroundColor Yellow
    ibmcloud plugin install container-registry -f
}
Write-Host "Plugins OK" -ForegroundColor Green

Write-Host ""

# Step 3: Login check
Write-Host "Step 2: Checking IBM Cloud login status..." -ForegroundColor Green
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

# Step 4: Target registry region
Write-Host "Step 3: Targeting IBM Container Registry (us-south)..." -ForegroundColor Green
ibmcloud cr region-set us-south | Out-Null
Write-Host "Registry: $registry" -ForegroundColor Green

Write-Host ""

# Step 5: Select Code Engine project
Write-Host "Step 4: Selecting Code Engine project..." -ForegroundColor Green
ibmcloud ce project select --name $projectName
if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to select project. Creating it..." -ForegroundColor Yellow
    ibmcloud ce project create --name $projectName
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to create project" -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }
    ibmcloud ce project select --name $projectName
}
Write-Host "Project selected" -ForegroundColor Green

Write-Host ""

# Step 6: Submit build run directly from local source (no build config needed)
Write-Host "Step 5: Building image from local source (this takes 3-5 minutes)..." -ForegroundColor Green
Write-Host "  Image : $imageFull" -ForegroundColor Cyan
Write-Host "  Source: . (local)" -ForegroundColor Cyan
Write-Host ""

ibmcloud ce buildrun submit --name $buildName --image $imageFull --source . --strategy dockerfile --size medium --wait
if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed. Fetching logs..." -ForegroundColor Red
    ibmcloud ce buildrun logs --name $buildName
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host "Build completed successfully" -ForegroundColor Green

Write-Host ""

# Step 8: Read environment variables from .env.local
Write-Host "Step 7: Preparing environment variables..." -ForegroundColor Green
$envArgs = @()

if (Test-Path ".env.local") {
    Write-Host "Reading from .env.local..." -ForegroundColor Cyan
    $envContent = Get-Content ".env.local"

    $apiKey  = ($envContent | Select-String "WATSONX_API_KEY=(.+)").Matches.Groups[1].Value
    $spaceId = ($envContent | Select-String "WATSONX_SPACE_ID=(.+)").Matches.Groups[1].Value
    $url     = ($envContent | Select-String "WATSONX_URL=(.+)").Matches.Groups[1].Value

    if ($apiKey -and $spaceId -and $url) {
        $envArgs = @("--env", "WATSONX_API_KEY=$apiKey", "--env", "WATSONX_SPACE_ID=$spaceId", "--env", "WATSONX_URL=$url", "--env", "NODE_ENV=production")
        Write-Host "Environment variables loaded" -ForegroundColor Green
    } else {
        Write-Host "Warning: Could not read all credentials from .env.local" -ForegroundColor Yellow
    }
} else {
    Write-Host "Warning: .env.local not found - no env vars will be updated" -ForegroundColor Yellow
}

Write-Host ""

# Step 9: Deploy / update Code Engine app
Write-Host "Step 8: Deploying application..." -ForegroundColor Green
$appExists = ibmcloud ce app get --name $appName 2>&1 | Select-String "Name:"

if ($appExists) {
    Write-Host "Updating existing app with new image..." -ForegroundColor Cyan
    ibmcloud ce app update --name $appName --image $imageFull @envArgs --wait
} else {
    Write-Host "Creating new app..." -ForegroundColor Cyan
    ibmcloud ce app create --name $appName --image $imageFull --port 3000 --min-scale 0 --max-scale 1 --cpu 0.25 --memory 0.5G @envArgs --wait
}

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "Deployment Failed" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "View logs with:" -ForegroundColor Yellow
    Write-Host "  ibmcloud ce app logs --name $appName" -ForegroundColor White
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Deployment Successful!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Get app URL
$appJson = ibmcloud ce app get --name $appName --output json 2>&1 | ConvertFrom-Json
$appUrl  = $appJson.status.url

if ($appUrl) {
    Write-Host "Your app is running at:" -ForegroundColor Green
    Write-Host "  $appUrl" -ForegroundColor Cyan
} else {
    Write-Host "Run this to get your URL:" -ForegroundColor Yellow
    Write-Host "  ibmcloud ce app get --name $appName" -ForegroundColor White
}

Write-Host ""
Write-Host "Useful commands:" -ForegroundColor Yellow
Write-Host "  View logs:   ibmcloud ce app logs --name $appName" -ForegroundColor White
Write-Host "  View status: ibmcloud ce app get --name $appName" -ForegroundColor White
Write-Host ""

Read-Host "Press Enter to exit"

# Made with Bob
