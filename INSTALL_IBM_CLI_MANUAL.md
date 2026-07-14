# Manual IBM Cloud CLI Installation Guide

The automated script encountered an issue. Follow these manual steps instead.

## Step 1: Download IBM Cloud CLI

1. **Open your web browser**
2. **Go to:** https://cloud.ibm.com/docs/cli?topic=cli-install-ibmcloud-cli
3. **Click:** "Download for Windows" button
4. **Save the file:** `IBM_Cloud_CLI.exe` to your Downloads folder

## Step 2: Install IBM Cloud CLI

1. **Navigate to your Downloads folder**
2. **Double-click:** `IBM_Cloud_CLI.exe`
3. **Follow the installation wizard:**
   - Click "Next"
   - Accept the license agreement
   - Choose installation location (default is fine)
   - Click "Install"
   - Click "Finish" when complete

## Step 3: Verify Installation

1. **Open a NEW PowerShell window** (important - must be new to pick up PATH changes)
2. **Run:**
   ```powershell
   ibmcloud --version
   ```
3. **You should see:** Version information (e.g., "ibmcloud version 2.x.x")

If you get "command not found", close PowerShell completely and open a new window.

## Step 4: Install Cloud Foundry Plugin

In PowerShell, run:
```powershell
ibmcloud plugin install cloud-foundry
```

When prompted, type `y` to confirm.

## Step 5: Verify Cloud Foundry Plugin

```powershell
ibmcloud plugin list
```

You should see `cloud-foundry` in the list.

## Step 6: Login to IBM Cloud

```powershell
ibmcloud login --sso
```

Follow these steps:
1. A URL will be displayed - copy it
2. Open the URL in your browser
3. Login with your IBM credentials
4. Copy the one-time passcode shown
5. Paste it back into PowerShell
6. Press Enter

## Step 7: Target Cloud Foundry

```powershell
ibmcloud target --cf
```

Select your organization and space when prompted.

## Step 8: Navigate to Your App

```powershell
cd "C:\Users\DavidChamak\Documents\`$user\market insights\IBM Bob Experiments\competitor-analyzer"
```

## Step 9: Set Environment Variables

You have two options:

### Option A: Set via CLI (Recommended)

```powershell
ibmcloud cf set-env competitor-analyzer-ibm WATSONX_API_KEY "your_api_key_here"
ibmcloud cf set-env competitor-analyzer-ibm WATSONX_SPACE_ID "your_space_id_here"
ibmcloud cf set-env competitor-analyzer-ibm WATSONX_URL "https://us-south.ml.cloud.ibm.com"
```

Replace `your_api_key_here` and `your_space_id_here` with your actual credentials from `.env.local`

### Option B: Use manifest.yml

Edit `manifest.yml` and add your environment variables:

```yaml
---
applications:
- name: competitor-analyzer-ibm
  memory: 512M
  instances: 1
  buildpacks:
    - nodejs_buildpack
  command: npm start
  env:
    NODE_ENV: production
    WATSONX_API_KEY: your_api_key_here
    WATSONX_SPACE_ID: your_space_id_here
    WATSONX_URL: https://us-south.ml.cloud.ibm.com
```

**Note:** This is less secure as credentials are in the file.

## Step 10: Deploy to IBM Cloud

```powershell
npm run deploy:ibm
```

Or:

```powershell
ibmcloud cf push
```

## Step 11: Monitor Deployment

The deployment will take 2-5 minutes. You'll see:
- Uploading files
- Staging application
- Starting application
- Route information

## Step 12: Access Your App

Once deployment completes, you'll see output like:

```
name:              competitor-analyzer-ibm
requested state:   started
routes:            competitor-analyzer-ibm.mybluemix.net
```

Open your browser to the route shown (e.g., `https://competitor-analyzer-ibm.mybluemix.net`)

## Troubleshooting

### "ibmcloud: command not found"
- Close PowerShell completely
- Open a NEW PowerShell window
- Try again

### "Failed to install plugin"
- Make sure you're connected to the internet
- Try: `ibmcloud plugin install cloud-foundry -f` (force install)

### "Authentication failed"
- Make sure you're using `--sso` flag: `ibmcloud login --sso`
- Check that you copied the passcode correctly

### "No org/space found"
- Contact your IBM Cloud administrator
- You may need to be added to an organization

### Deployment fails
- Check logs: `ibmcloud cf logs competitor-analyzer-ibm --recent`
- Verify environment variables are set
- Make sure `package.json` and `manifest.yml` are correct

## Quick Reference Commands

```powershell
# Check CLI version
ibmcloud --version

# Login
ibmcloud login --sso

# Target org/space
ibmcloud target --cf

# Deploy
ibmcloud cf push

# View logs
ibmcloud cf logs competitor-analyzer-ibm --recent

# Check app status
ibmcloud cf app competitor-analyzer-ibm

# Set environment variable
ibmcloud cf set-env competitor-analyzer-ibm VAR_NAME "value"
ibmcloud cf restage competitor-analyzer-ibm

# Restart app
ibmcloud cf restart competitor-analyzer-ibm
```

## Alternative: Use IBM Cloud Web Console

If CLI installation continues to have issues:

1. Go to: https://cloud.ibm.com
2. Login with your IBM credentials
3. Navigate to: Cloud Foundry → Apps
4. Click "Create app"
5. Upload your application files manually
6. Set environment variables in the web console

## Need Help?

- See: `IBM_CLOUD_DEPLOYMENT.md` for detailed information
- See: `QUICK_DEPLOY_IBM.md` for quick checklist
- IBM Cloud Docs: https://cloud.ibm.com/docs

---

**Note:** The automated script had issues with the downloaded installer. This manual process is more reliable.