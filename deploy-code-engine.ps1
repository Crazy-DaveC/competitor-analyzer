# IBM Code Engine Deployment Script
# Commits local changes to GitHub, then triggers a Code Engine build + deploy

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "IBM Code Engine Deployment Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Config
$projectName     = "competitor-analyzer"
$appName         = "competitor-analyzer"
$buildName       = "competitor-analyzer-build"
$namespace       = "ce--0d7a9-2bt5rda2txf2"
$registry        = "private.us.icr.io"
$imageFull       = "$registry/$namespace/competitor-analyzer-image:latest"
$gitRepo         = "https://github.com/Crazy-DaveC/competitor-analyzer"
$gitBranch       = "master"
$registrySecret  = "ce-auto-icr-private-us-south"

# Ensure Git and GitHub CLI are on PATH
$env:PATH = "C:\Program Files\Git\cmd;C:\Program Files\GitHub CLI;" + $env:PATH

# Step 1: Commit and push latest changes to GitHub
Write-Host "Step 1: Pushing latest changes to GitHub..." -ForegroundColor Green

$status = git status --porcelain 2>&1
if ($status) {
    Write-Host "  Uncommitted changes found - committing..." -ForegroundColor Cyan
    git add -A
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
    git commit -m "Deploy update $timestamp"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Git commit failed" -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }
} else {
    Write-Host "  No changes to commit" -ForegroundColor Cyan
}

git push origin $gitBranch
if ($LASTEXITCODE -ne 0) {
    Write-Host "Git push failed" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host "  Code pushed to $gitRepo" -ForegroundColor Green

Write-Host ""

# Step 2: Check IBM Cloud CLI
Write-Host "Step 2: Checking IBM Cloud CLI..." -ForegroundColor Green
try {
    $version = ibmcloud --version 2>&1
    Write-Host "  $version" -ForegroundColor Cyan
} catch {
    Write-Host "ERROR: IBM Cloud CLI not found!" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""

# Step 3: Login check
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
    Write-Host "  Already logged in" -ForegroundColor Green
}

Write-Host ""

# Step 4: Select Code Engine project
Write-Host "Step 4: Selecting Code Engine project..." -ForegroundColor Green
ibmcloud ce project select --name $projectName 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to select project" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host "  Project: $projectName" -ForegroundColor Green

Write-Host ""

# Step 5: Create or update the stored build config (uses GitHub URL as source)
Write-Host "Step 5: Configuring build from GitHub..." -ForegroundColor Green
Write-Host "  Source: $gitRepo" -ForegroundColor Cyan
Write-Host "  Image : $imageFull" -ForegroundColor Cyan

$buildExists = ibmcloud ce build get --name $buildName 2>&1 | Select-String "Name:"

if ($buildExists) {
    Write-Host "  Updating existing build config..." -ForegroundColor Cyan
    ibmcloud ce build update --name $buildName --image $imageFull --source $gitRepo --commit $gitBranch --registry-secret $registrySecret 2>&1 | Out-Null
} else {
    Write-Host "  Creating build config..." -ForegroundColor Cyan
    ibmcloud ce build create --name $buildName --image $imageFull --source $gitRepo --commit $gitBranch --strategy dockerfile --size medium --registry-secret $registrySecret 2>&1
}

if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to configure build" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host "  Build config ready" -ForegroundColor Green

Write-Host ""

# Step 6: Run the build
Write-Host "Step 6: Building image (3-5 minutes)..." -ForegroundColor Green
ibmcloud ce buildrun submit --build $buildName --wait
if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed. Fetching logs..." -ForegroundColor Red
    $lastRun = ibmcloud ce buildrun list --output json 2>&1 | ConvertFrom-Json | Where-Object { $_.metadata.labels.'buildrun.serving.knative.dev/buildName' -eq $buildName -or $_.metadata.name -like "$buildName*" } | Select-Object -Last 1
    if ($lastRun) { ibmcloud ce buildrun logs --buildrun $lastRun.metadata.name }
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host "  Build complete" -ForegroundColor Green

Write-Host ""

# Step 7: Read environment variables from .env.local
Write-Host "Step 7: Preparing environment variables..." -ForegroundColor Green
$envArgs = @()

if (Test-Path ".env.local") {
    $envContent = Get-Content ".env.local"
    $apiKey  = ($envContent | Select-String "WATSONX_API_KEY=(.+)").Matches.Groups[1].Value
    $spaceId = ($envContent | Select-String "WATSONX_SPACE_ID=(.+)").Matches.Groups[1].Value
    $url     = ($envContent | Select-String "WATSONX_URL=(.+)").Matches.Groups[1].Value

    if ($apiKey -and $spaceId -and $url) {
        $envArgs = @("--env", "WATSONX_API_KEY=$apiKey", "--env", "WATSONX_SPACE_ID=$spaceId", "--env", "WATSONX_URL=$url", "--env", "NODE_ENV=production")
        Write-Host "  Environment variables loaded from .env.local" -ForegroundColor Green
    } else {
        Write-Host "  Warning: Could not read all credentials from .env.local" -ForegroundColor Yellow
    }
} else {
    Write-Host "  Warning: .env.local not found - env vars will not be updated" -ForegroundColor Yellow
}

Write-Host ""

# Step 8: Deploy / update the Code Engine app
Write-Host "Step 8: Deploying to Code Engine..." -ForegroundColor Green
$appExists = ibmcloud ce app get --name $appName 2>&1 | Select-String "Name:"

if ($appExists) {
    Write-Host "  Updating existing app..." -ForegroundColor Cyan
    ibmcloud ce app update --name $appName --image $imageFull @envArgs --wait
} else {
    Write-Host "  Creating new app..." -ForegroundColor Cyan
    ibmcloud ce app create --name $appName --image $imageFull --port 3000 --min-scale 0 --max-scale 1 --cpu 0.25 --memory 0.5G @envArgs --wait
}

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "Deployment Failed" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "View logs: ibmcloud ce app logs --name $appName" -ForegroundColor White
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Deployment Successful!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$appJson = ibmcloud ce app get --name $appName --output json 2>&1 | ConvertFrom-Json
$appUrl  = $appJson.status.url

if ($appUrl) {
    Write-Host "Your app is running at:" -ForegroundColor Green
    Write-Host "  $appUrl" -ForegroundColor Cyan
} else {
    Write-Host "Run: ibmcloud ce app get --name $appName" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Useful commands:" -ForegroundColor Yellow
Write-Host "  View logs:   ibmcloud ce app logs --name $appName" -ForegroundColor White
Write-Host "  View status: ibmcloud ce app get --name $appName" -ForegroundColor White
Write-Host ""

Read-Host "Press Enter to exit"

# Made with Bob
