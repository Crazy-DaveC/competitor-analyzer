# IBM Cloud Deployment Guide

This guide will help you deploy the Competitor Message Analyzer to IBM Cloud, allowing you to use it with IBM confidential information securely within IBM's infrastructure.

## Prerequisites

1. **IBM Cloud Account**: You need an active IBM Cloud account
2. **IBM Cloud CLI**: Install the IBM Cloud CLI
3. **Cloud Foundry CLI**: Install the Cloud Foundry CLI plugin
4. **IBM watsonx.ai Access**: Ensure you have access to watsonx.ai in your IBM Cloud account

## Installation Steps

### 1. Install IBM Cloud CLI

**Windows (PowerShell):**
```powershell
# Download and run the installer
Invoke-WebRequest -Uri "https://clis.cloud.ibm.com/download/bluemix-cli/latest/win64" -OutFile "IBM_Cloud_CLI.exe"
.\IBM_Cloud_CLI.exe
```

**Or download from:** https://cloud.ibm.com/docs/cli?topic=cli-install-ibmcloud-cli

### 2. Install Cloud Foundry Plugin

```bash
ibmcloud plugin install cloud-foundry
```

### 3. Login to IBM Cloud

```bash
ibmcloud login
```

If you use SSO:
```bash
ibmcloud login --sso
```

### 4. Target Cloud Foundry Organization and Space

```bash
# List available orgs
ibmcloud target --cf

# Or specify org and space
ibmcloud target -o YOUR_ORG -s YOUR_SPACE
```

## Configuration

### 1. Set Environment Variables in IBM Cloud

You need to set your watsonx.ai credentials as environment variables in IBM Cloud. You have two options:

#### Option A: Set via CLI (Recommended for Security)

```bash
cd competitor-analyzer

# Set environment variables
ibmcloud cf set-env competitor-analyzer-ibm WATSONX_API_KEY "your_api_key_here"
ibmcloud cf set-env competitor-analyzer-ibm WATSONX_SPACE_ID "your_space_id_here"
ibmcloud cf set-env competitor-analyzer-ibm WATSONX_URL "https://us-south.ml.cloud.ibm.com"
```

#### Option B: Create .env file for IBM Cloud

Create a file named `.env.ibm` in the `competitor-analyzer` directory:

```env
WATSONX_API_KEY=your_actual_api_key
WATSONX_SPACE_ID=your_actual_space_id
WATSONX_URL=https://us-south.ml.cloud.ibm.com
```

**Note:** This file is NOT committed to git for security reasons.

### 2. Update manifest.yml (Optional)

Edit `manifest.yml` to customize:
- **name**: Change `competitor-analyzer-ibm` to your preferred app name
- **memory**: Adjust if needed (512M is recommended minimum)
- **route**: Change the URL if desired

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
```

## Deployment

### Deploy to IBM Cloud

From the `competitor-analyzer` directory:

```bash
# Navigate to the app directory
cd competitor-analyzer

# Deploy the application
ibmcloud cf push
```

Or use the npm script:

```bash
npm run deploy:ibm
```

### Monitor Deployment

```bash
# Check app status
ibmcloud cf app competitor-analyzer-ibm

# View logs
ibmcloud cf logs competitor-analyzer-ibm --recent

# Stream logs in real-time
ibmcloud cf logs competitor-analyzer-ibm
```

## Post-Deployment

### 1. Verify Deployment

After deployment completes, you'll see output like:

```
name:              competitor-analyzer-ibm
requested state:   started
routes:            competitor-analyzer-ibm.mybluemix.net
```

### 2. Access Your Application

Open your browser and navigate to:
```
https://competitor-analyzer-ibm.mybluemix.net
```

(Replace with your actual route from the deployment output)

### 3. Test the Application

1. Enter target audiences (e.g., "CIOs", "IT Managers")
2. Paste a marketing message
3. Enter competitors (e.g., "Microsoft", "Oracle")
4. Click "Analyze Competitor Responses"
5. Review the AI-generated analysis

## Environment Variables Management

### View Current Environment Variables

```bash
ibmcloud cf env competitor-analyzer-ibm
```

### Update Environment Variables

```bash
ibmcloud cf set-env competitor-analyzer-ibm VARIABLE_NAME "new_value"
ibmcloud cf restage competitor-analyzer-ibm
```

### Remove Environment Variables

```bash
ibmcloud cf unset-env competitor-analyzer-ibm VARIABLE_NAME
ibmcloud cf restage competitor-analyzer-ibm
```

## Scaling

### Scale Instances

```bash
# Scale to 2 instances
ibmcloud cf scale competitor-analyzer-ibm -i 2

# Scale memory
ibmcloud cf scale competitor-analyzer-ibm -m 1G
```

## Troubleshooting

### Check Application Logs

```bash
# Recent logs
ibmcloud cf logs competitor-analyzer-ibm --recent

# Stream logs
ibmcloud cf logs competitor-analyzer-ibm
```

### Common Issues

#### 1. Build Fails

**Error:** `npm install` fails during staging

**Solution:** Ensure `package.json` and `package-lock.json` are present and valid

```bash
# Test locally first
npm install
npm run build
npm start
```

#### 2. Application Crashes

**Error:** App crashes immediately after deployment

**Solution:** Check logs and verify environment variables

```bash
ibmcloud cf logs competitor-analyzer-ibm --recent
ibmcloud cf env competitor-analyzer-ibm
```

#### 3. watsonx.ai Connection Issues

**Error:** "Missing AI credentials" or API errors

**Solution:** Verify environment variables are set correctly

```bash
# Check environment variables
ibmcloud cf env competitor-analyzer-ibm

# Reset if needed
ibmcloud cf set-env competitor-analyzer-ibm WATSONX_API_KEY "your_key"
ibmcloud cf set-env competitor-analyzer-ibm WATSONX_SPACE_ID "your_space_id"
ibmcloud cf restage competitor-analyzer-ibm
```

#### 4. Memory Issues

**Error:** App crashes with out-of-memory errors

**Solution:** Increase memory allocation

```bash
ibmcloud cf scale competitor-analyzer-ibm -m 1G
```

### Restart Application

```bash
ibmcloud cf restart competitor-analyzer-ibm
```

### Restage Application

Use this after changing environment variables:

```bash
ibmcloud cf restage competitor-analyzer-ibm
```

## Security Best Practices

### 1. Environment Variables

- **Never commit** `.env.ibm` or `.env.local` to version control
- Use IBM Cloud's environment variable management
- Rotate API keys regularly

### 2. Access Control

- Limit access to the IBM Cloud space
- Use IBM Cloud IAM for user management
- Enable audit logging

### 3. Network Security

- Consider using IBM Cloud Private endpoints
- Enable HTTPS (automatic with Cloud Foundry)
- Use IBM Cloud Security Groups if needed

### 4. Data Handling

- This app processes confidential IBM information
- Ensure compliance with IBM data policies
- Review watsonx.ai data retention policies

## Updating the Application

### Deploy Updates

```bash
cd competitor-analyzer

# Pull latest changes (if using git)
git pull

# Deploy updates
ibmcloud cf push
```

Or use the npm script:

```bash
npm run deploy:ibm
```

### Zero-Downtime Deployment

```bash
# Deploy with blue-green strategy
ibmcloud cf push competitor-analyzer-ibm-new
# Test the new version
# Switch routes when ready
ibmcloud cf map-route competitor-analyzer-ibm-new mybluemix.net --hostname competitor-analyzer-ibm
ibmcloud cf unmap-route competitor-analyzer-ibm mybluemix.net --hostname competitor-analyzer-ibm
ibmcloud cf delete competitor-analyzer-ibm -f
ibmcloud cf rename competitor-analyzer-ibm-new competitor-analyzer-ibm
```

## Monitoring and Maintenance

### Health Check

```bash
# Check app health
ibmcloud cf app competitor-analyzer-ibm
```

### Resource Usage

```bash
# View app statistics
ibmcloud cf app competitor-analyzer-ibm
```

### Set Up Alerts

Consider setting up IBM Cloud monitoring and alerts for:
- Application availability
- Response time
- Error rates
- Memory usage

## Cost Management

### Estimate Costs

- Cloud Foundry app: Based on memory and instances
- watsonx.ai: Based on API usage
- Network egress: Typically minimal

### Optimize Costs

1. **Right-size memory**: Start with 512M, adjust as needed
2. **Scale instances**: Use 1 instance for development, scale for production
3. **Monitor usage**: Review watsonx.ai API usage regularly

## Comparison: Vercel vs IBM Cloud

| Feature | Vercel (Current) | IBM Cloud (New) |
|---------|------------------|-----------------|
| **Security** | Public cloud | IBM internal cloud |
| **Data** | External | IBM confidential OK |
| **Compliance** | General | IBM policies |
| **Cost** | Free tier available | Pay-as-you-go |
| **Deployment** | Git push | CLI push |
| **Scaling** | Automatic | Manual/Auto |

## Support

### IBM Cloud Support

- IBM Cloud Docs: https://cloud.ibm.com/docs
- Cloud Foundry Docs: https://docs.cloudfoundry.org
- watsonx.ai Docs: https://cloud.ibm.com/docs/watsonx

### Internal Support

- Contact your IBM Cloud administrator
- Review IBM internal deployment guidelines
- Check IBM security and compliance requirements

## Next Steps

1. ✅ Deploy to IBM Cloud using this guide
2. ✅ Test with sample messages
3. ✅ Configure access controls
4. ✅ Set up monitoring
5. ✅ Train your team on the tool
6. ✅ Keep Vercel deployment for non-confidential use

---

**Note:** The Vercel deployment remains active for non-confidential use cases. Use the IBM Cloud deployment specifically for analyzing IBM confidential information.

## Quick Reference Commands

```bash
# Login
ibmcloud login --sso

# Target org/space
ibmcloud target --cf

# Deploy
cd competitor-analyzer
ibmcloud cf push

# View logs
ibmcloud cf logs competitor-analyzer-ibm --recent

# Set env var
ibmcloud cf set-env competitor-analyzer-ibm VAR_NAME "value"
ibmcloud cf restage competitor-analyzer-ibm

# Scale
ibmcloud cf scale competitor-analyzer-ibm -i 2 -m 1G

# Restart
ibmcloud cf restart competitor-analyzer-ibm
```

---

Built for IBM Cloud with security and compliance in mind.