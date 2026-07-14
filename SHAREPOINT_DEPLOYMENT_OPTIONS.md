# SharePoint Deployment Options for Competitor Analyzer

## Understanding SharePoint App Development

SharePoint supports specific types of applications, but **cannot run Node.js/Next.js apps directly**. Here are your options:

---

## Option 1: SharePoint Framework (SPFx) Web Part ⚠️ MAJOR REWRITE

### What is SPFx?
- Microsoft's official framework for SharePoint customization
- Uses **React** (which we already use) + TypeScript
- Runs **client-side only** (in the browser)
- No server-side code execution

### Architecture Changes Required:

```
Current Architecture (Next.js):
┌─────────────┐      ┌──────────────┐      ┌─────────────┐
│   Browser   │ ───> │  Next.js API │ ───> │ IBM watsonx │
│  (React UI) │ <─── │   (Node.js)  │ <─── │     AI      │
└─────────────┘      └──────────────┘      └─────────────┘

SPFx Architecture (Required for SharePoint):
┌─────────────────────────────────────┐      ┌─────────────┐
│         Browser (SPFx)              │ ───> │ IBM watsonx │
│  React UI + Direct API Calls        │ <─── │     AI      │
└─────────────────────────────────────┘      └─────────────┘
```

### What This Means:
1. **Remove Next.js API route** (`app/api/competitor-analysis/route.ts`)
2. **Call IBM watsonx directly from browser** (client-side)
3. **Expose API keys in browser** ⚠️ SECURITY RISK
4. **Rewrite using SPFx tooling** (Yeoman generator, Gulp)
5. **Package as .sppkg file** for SharePoint deployment

### Major Limitations:
- ❌ **API keys visible in browser** (anyone can steal them)
- ❌ **No server-side security**
- ❌ **CORS issues** with IBM watsonx API
- ❌ **Complete rewrite required** (2-3 days of work)
- ❌ **Complex deployment process**

### Development Steps (If You Choose This):
```powershell
# 1. Install SPFx prerequisites
npm install -g yo @microsoft/generator-sharepoint

# 2. Create new SPFx project
yo @microsoft/sharepoint

# 3. Migrate React components
# 4. Implement client-side API calls
# 5. Handle authentication
# 6. Package and deploy
gulp bundle --ship
gulp package-solution --ship
```

---

## Option 2: SharePoint + External API (RECOMMENDED) ✅

### Architecture:
```
┌──────────────┐      ┌─────────────────┐      ┌─────────────┐
│  SharePoint  │ ───> │  External API   │ ───> │ IBM watsonx │
│  (SPFx UI)   │ <─── │ (Azure/IBM/AWS) │ <─── │     AI      │
└──────────────┘      └─────────────────┘      └─────────────┘
```

### How It Works:
1. **Keep your Next.js app** (no rewrite needed)
2. **Deploy API to secure cloud** (Azure, IBM Cloud, or AWS)
3. **Create SPFx web part** that calls your API
4. **API handles authentication** and IBM watsonx calls
5. **SharePoint just displays the UI**

### Benefits:
- ✅ **API keys stay secure** on server
- ✅ **Minimal rewrite** (just create SPFx wrapper)
- ✅ **Use existing Next.js code**
- ✅ **Better security**
- ✅ **Easier maintenance**

### Implementation:
```typescript
// SPFx Web Part calls your deployed API
const response = await fetch('https://your-api.azurewebsites.net/api/analyze', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${userToken}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({ message, audiences, competitors })
});
```

---

## Option 3: Power Apps + Power Automate 🔄

### What is Power Apps?
- Microsoft's low-code platform
- Integrates natively with SharePoint
- Can call external APIs via Power Automate

### Architecture:
```
┌──────────────┐      ┌─────────────────┐      ┌─────────────┐
│  Power App   │ ───> │ Power Automate  │ ───> │ IBM watsonx │
│  (SharePoint)│ <─── │     (Flow)      │ <─── │     API     │
└──────────────┘      └─────────────────┘      └─────────────┘
```

### Pros:
- ✅ Native SharePoint integration
- ✅ No coding required (mostly)
- ✅ Secure credential storage
- ✅ Easy for non-developers to maintain

### Cons:
- ❌ Limited UI customization
- ❌ Different development paradigm
- ❌ May require Power Apps license
- ❌ Complete rebuild required

---

## Option 4: SharePoint Page + iFrame (SIMPLEST) 🎯

### How It Works:
1. **Keep your Vercel/IBM Cloud deployment**
2. **Create SharePoint page**
3. **Embed your app in an iFrame**
4. **Control access via SharePoint permissions**

### Implementation:
```html
<!-- SharePoint Page Content -->
<iframe 
  src="https://your-app.vercel.app" 
  width="100%" 
  height="800px"
  style="border: none;">
</iframe>
```

### Benefits:
- ✅ **Zero code changes** required
- ✅ **5 minutes to implement**
- ✅ **SharePoint handles access control**
- ✅ **Keep existing deployment**

### Limitations:
- ⚠️ Data still goes to external service (Vercel/IBM)
- ⚠️ Not truly "running in SharePoint"
- ⚠️ Users see external URL in browser tools

---

## 🎯 RECOMMENDATION: Hybrid Approach

### For Confidential Data:
**Run locally** on your machine:
```powershell
cd competitor-analyzer
npm run dev
# Access at http://localhost:3000
```

### For Team Sharing (Non-Confidential):
1. **Keep Vercel deployment** for demos
2. **Use SharePoint for**:
   - Storing analysis results (PDFs, reports)
   - Team collaboration on findings
   - Document management
   - Access control

### For Secure Team Access (Confidential):
**Deploy to Azure App Service** (integrates with SharePoint):
```powershell
# Azure CLI deployment
az webapp up --name competitor-analyzer --resource-group myResourceGroup
```

Then embed in SharePoint via iFrame or create SPFx wrapper.

---

## 📊 Comparison Table

| Option | Effort | Security | Cost | Best For |
|--------|--------|----------|------|----------|
| **SPFx Only** | 🔴 High (rewrite) | 🔴 Low (exposed keys) | Free | Not recommended |
| **SPFx + External API** | 🟡 Medium | 🟢 High | $5-15/mo | Team access |
| **Power Apps** | 🟡 Medium | 🟢 High | $5-20/user/mo | Non-technical teams |
| **iFrame Embed** | 🟢 Low (5 min) | 🟡 Medium | Free-$15/mo | Quick solution |
| **Local + SharePoint** | 🟢 Low | 🟢 Highest | Free | Confidential data |

---

## 🚀 Quick Decision Guide

**Choose Local Deployment if:**
- Data is highly confidential
- Only you need to use it
- No budget for cloud services

**Choose Azure + SPFx if:**
- Team needs access
- Data is confidential
- You have Microsoft 365/Azure

**Choose iFrame Embed if:**
- Need quick solution
- Data is not highly sensitive
- Want minimal changes

**Choose Power Apps if:**
- Non-technical team will maintain
- Native SharePoint integration required
- Have Power Apps licenses

---

## 💡 My Recommendation

**For your use case (confidential data):**

1. **Immediate solution**: Run locally (`npm run dev`)
2. **Team access**: Deploy to Azure App Service + embed in SharePoint
3. **Long-term**: Consider IBM Cloud paid account for enterprise security

**Do NOT:**
- Rewrite as pure SPFx (exposes API keys)
- Upload confidential data to Vercel
- Use Power Apps (overkill for this use case)

---

## 📋 Next Steps

Would you like me to:
1. ✅ Set up local deployment for confidential use?
2. ✅ Create Azure deployment guide with SharePoint integration?
3. ✅ Build simple iFrame embed solution?
4. ❌ Rewrite as SPFx (not recommended for security reasons)?

---

**Bottom Line**: SharePoint cannot run Node.js apps natively. You need either:
- External hosting (Azure/IBM/AWS) + SharePoint UI wrapper
- Local deployment for confidential data
- Hybrid approach using SharePoint for storage only