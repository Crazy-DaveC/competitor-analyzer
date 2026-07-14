# IBM Code Engine Deployment Guide

IBM Code Engine is the modern, serverless platform that replaces Cloud Foundry on IBM Cloud.

## Prerequisites

1. **IBM Cloud CLI installed**
   ```powershell
   .\install-ibm-cli.ps1
   ```

2. **IBM Cloud account** with access to Code Engine

## Quick Deploy

Run the automated deployment script:

```powershell
cd competitor-analyzer
.\deploy-code-engine.ps1
```

The script will:
1. ✅ Install Code Engine plugin
2. ✅ Login to IBM Cloud (if needed)
3. ✅ Create/select Code Engine project
4. ✅ Build container image from Dockerfile
5. ✅ Deploy application with environment variables
6. ✅ Provide your app URL

## What You'll Be Asked

### 1. Resource Group
- Default: `default`
- Or choose from your available resource groups

### 2. Region (if creating new project)
- **us-south** (Dallas) - Recommended for US
- **us-east** (Washington DC)
- **eu-de** (Frankfurt) - Recommended for Europe
- **eu-gb** (London)
- **jp-tok** (Tokyo) - Recommended for Asia

## Manual Deployment Steps

If you prefer manual control:

### 1. Install Code Engine Plugin
```powershell
ibmcloud plugin install code-engine
```

### 2. Login to IBM Cloud
```powershell
ibmcloud login --sso
```

### 3. Target Resource Group
```powershell
ibmcloud target -g default
```

### 4. Create Code Engine Project
```powershell
ibmcloud ce project create --name competitor-analyzer --region us-south
```

### 5. Select Project
```powershell
ibmcloud ce project select --name competitor-analyzer
```

### 6. Build Container Image
```powershell
ibmcloud ce build create --name competitor-analyzer-build --image us.icr.io/$USERNAME/competitor-analyzer-image --source . --strategy dockerfile --size medium

ibmcloud ce buildrun submit --build competitor-analyzer-build --wait
```

### 7. Deploy Application
```powershell
ibmcloud ce app create --name competitor-analyzer-app `
  --image us.icr.io/$USERNAME/competitor-analyzer-image `
  --port 3000 `
  --min-scale 0 `
  --max-scale 1 `
  --cpu 0.25 `
  --memory 0.5G `
  --env WATSONX_API_KEY=your_api_key `
  --env WATSONX_SPACE_ID=your_space_id `
  --env WATSONX_URL=your_url `
  --env NODE_ENV=production
```

### 8. Get Application URL
```powershell
ibmcloud ce app get --name competitor-analyzer-app
```

## Useful Commands

### View Application Status
```powershell
ibmcloud ce app get --name competitor-analyzer-app
```

### View Logs
```powershell
ibmcloud ce app logs --name competitor-analyzer-app
```

### Update Application
```powershell
ibmcloud ce app update --name competitor-analyzer-app --image us.icr.io/$USERNAME/competitor-analyzer-image
```

### List All Applications
```powershell
ibmcloud ce app list
```

### Delete Application
```powershell
ibmcloud ce app delete --name competitor-analyzer-app
```

### View Build Logs
```powershell
ibmcloud ce buildrun logs --build competitor-analyzer-build
```

## Pricing

Code Engine pricing is based on:
- **vCPU-seconds**: $0.00003417 per vCPU-second
- **Memory GB-seconds**: $0.00000356 per GB-second
- **Free tier**: 100,000 vCPU-seconds and 200,000 GB-seconds per month

With the default configuration (0.25 vCPU, 0.5GB RAM):
- **Idle cost**: $0 (scales to zero when not in use)
- **Active cost**: ~$0.05 per hour of active use
- **Monthly estimate**: $5-10 for moderate use

## Advantages Over Cloud Foundry

✅ **Serverless**: Scales to zero when not in use (no idle costs)
✅ **Modern**: Container-based deployment
✅ **Flexible**: More control over resources
✅ **Cost-effective**: Pay only for actual usage
✅ **Faster**: Quicker cold starts
✅ **Supported**: Active development and support

## Troubleshooting

### Build Fails
```powershell
# View build logs
ibmcloud ce buildrun logs --build competitor-analyzer-build

# Common issues:
# - Dockerfile syntax errors
# - Missing dependencies in package.json
# - Build timeout (increase size to 'large')
```

### Application Won't Start
```powershell
# View application logs
ibmcloud ce app logs --name competitor-analyzer-app

# Common issues:
# - Missing environment variables
# - Port mismatch (must be 3000)
# - Application crashes on startup
```

### Can't Access Application
```powershell
# Check application status
ibmcloud ce app get --name competitor-analyzer-app

# Verify:
# - Application is in 'Ready' state
# - URL is accessible
# - No firewall blocking access
```

## Environment Variables

The deployment script automatically reads from `.env.local`:
- `WATSONX_API_KEY`
- `WATSONX_SPACE_ID`
- `WATSONX_URL`

To update environment variables after deployment:
```powershell
ibmcloud ce app update --name competitor-analyzer-app --env KEY=VALUE
```

## Next Steps

After successful deployment:
1. ✅ Test your application at the provided URL
2. ✅ Monitor logs for any issues
3. ✅ Set up custom domain (optional)
4. ✅ Configure auto-scaling (optional)

## Support

- [IBM Code Engine Documentation](https://cloud.ibm.com/docs/codeengine)
- [IBM Cloud Support](https://cloud.ibm.com/unifiedsupport/supportcenter)

---

Made with Bob 🤖