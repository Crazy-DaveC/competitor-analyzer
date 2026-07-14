# Quick Deploy to IBM Cloud - Checklist

Follow these steps to deploy the Competitor Message Analyzer to IBM Cloud.

## Prerequisites Checklist

- [ ] IBM Cloud account with active subscription
- [ ] IBM watsonx.ai access enabled
- [ ] IBM Cloud CLI installed
- [ ] Cloud Foundry plugin installed
- [ ] watsonx.ai API key and Space ID ready

## Deployment Steps

### 1. Install IBM Cloud CLI (if not already installed)

**Windows:**
```powershell
# Download from: https://cloud.ibm.com/docs/cli?topic=cli-install-ibmcloud-cli
# Or use installer
```

### 2. Install Cloud Foundry Plugin

```bash
ibmcloud plugin install cloud-foundry
```

### 3. Login to IBM Cloud

```bash
ibmcloud login --sso
```

Follow the prompts to authenticate.

### 4. Target Your Cloud Foundry Org and Space

```bash
ibmcloud target --cf
```

Select your organization and space when prompted.

### 5. Navigate to Application Directory

```bash
cd "c:/Users/DavidChamak/Documents/$user/market insights/IBM Bob Experiments/competitor-analyzer"
```

### 6. Set Environment Variables

**Option A: Set via CLI (Recommended)**

```bash
ibmcloud cf set-env competitor-analyzer-ibm WATSONX_API_KEY "your_api_key_here"
ibmcloud cf set-env competitor-analyzer-ibm WATSONX_SPACE_ID "your_space_id_here"
ibmcloud cf set-env competitor-analyzer-ibm WATSONX_URL "https://us-south.ml.cloud.ibm.com"
```

**Option B: Create .env.ibm file**

Create `.env.ibm` with your credentials (this file is gitignored):
```env
WATSONX_API_KEY=your_actual_api_key
WATSONX_SPACE_ID=your_actual_space_id
WATSONX_URL=https://us-south.ml.cloud.ibm.com
```

### 7. Deploy to IBM Cloud

```bash
ibmcloud cf push
```

Or use the npm script:
```bash
npm run deploy:ibm
```

### 8. Wait for Deployment

The deployment will take 2-5 minutes. You'll see output like:

```
Uploading app files...
Staging app...
Starting app...
name:              competitor-analyzer-ibm
requested state:   started
routes:            competitor-analyzer-ibm.mybluemix.net
```

### 9. Verify Deployment

```bash
ibmcloud cf app competitor-analyzer-ibm
```

### 10. Access Your Application

Open your browser to:
```
https://competitor-analyzer-ibm.mybluemix.net
```

(Use the actual route from your deployment output)

## Post-Deployment

### View Logs

```bash
# Recent logs
ibmcloud cf logs competitor-analyzer-ibm --recent

# Stream logs
ibmcloud cf logs competitor-analyzer-ibm
```

### Test the Application

1. Enter target audiences (e.g., "CIOs", "IT Managers")
2. Paste a marketing message
3. Enter competitors (e.g., "Microsoft", "Oracle")
4. Click "Analyze Competitor Responses"
5. Review the AI-generated analysis

### Update Environment Variables (if needed)

```bash
ibmcloud cf set-env competitor-analyzer-ibm VARIABLE_NAME "new_value"
ibmcloud cf restage competitor-analyzer-ibm
```

## Troubleshooting

### Build Fails

```bash
# Check logs
ibmcloud cf logs competitor-analyzer-ibm --recent

# Verify package.json exists
ls package.json
```

### App Crashes

```bash
# Check app status
ibmcloud cf app competitor-analyzer-ibm

# View recent logs
ibmcloud cf logs competitor-analyzer-ibm --recent

# Restart app
ibmcloud cf restart competitor-analyzer-ibm
```

### Environment Variable Issues

```bash
# Check current environment variables
ibmcloud cf env competitor-analyzer-ibm

# Reset variables
ibmcloud cf set-env competitor-analyzer-ibm WATSONX_API_KEY "your_key"
ibmcloud cf set-env competitor-analyzer-ibm WATSONX_SPACE_ID "your_space_id"
ibmcloud cf restage competitor-analyzer-ibm
```

## Quick Commands Reference

```bash
# Deploy
ibmcloud cf push

# View logs
ibmcloud cf logs competitor-analyzer-ibm --recent

# Restart
ibmcloud cf restart competitor-analyzer-ibm

# Check status
ibmcloud cf app competitor-analyzer-ibm

# Scale
ibmcloud cf scale competitor-analyzer-ibm -i 2 -m 1G

# Delete (if needed)
ibmcloud cf delete competitor-analyzer-ibm
```

## Success Criteria

- [ ] Application deployed successfully
- [ ] No errors in logs
- [ ] Application accessible via URL
- [ ] Can submit analysis requests
- [ ] Receives AI-generated responses
- [ ] Environment variables set correctly

## Next Steps

1. ✅ Share the IBM Cloud URL with your team
2. ✅ Set up access controls if needed
3. ✅ Configure monitoring and alerts
4. ✅ Document the deployment for your team
5. ✅ Keep Vercel deployment for non-confidential use

## Support

For detailed information, see:
- `IBM_CLOUD_DEPLOYMENT.md` - Full deployment guide
- `DEPLOYMENT_COMPARISON.md` - Vercel vs IBM Cloud comparison
- `README.md` - Application documentation

---

**Remember:** Use this IBM Cloud deployment for IBM confidential information. Keep the Vercel deployment for non-confidential use cases.