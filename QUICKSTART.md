# Competitor Response Analyzer - Quick Start Guide

## 🎯 What This Tool Does

Predicts how competitors will respond to your marketing messages using IBM watsonx.ai.

## 📁 Project Location

This is a **separate, standalone project** in:
```
competitor-analyzer/
```

Your original MMAPI Message Tester remains unchanged in the parent directory.

## ⚡ Quick Setup (3 Steps)

### 1. Navigate to the Project
```bash
cd competitor-analyzer
```

### 2. Install Dependencies
```bash
npm install
```

### 3. Add Your IBM Credentials

Edit the `.env` file in this directory:
```env
WATSONX_API_KEY=your_actual_api_key_here
WATSONX_PROJECT_ID=your_actual_project_id_here
```

**Important:** Replace the placeholder values with your actual IBM watsonx.ai credentials.

## 🚀 Run the Application

```bash
npm run dev
```

Open your browser to: **http://localhost:3000**

## 📝 How to Use

1. **Enter Target Audiences**
   - Add one or more audiences (e.g., "CIOs", "Marketing Directors")
   - Click "+ Add Audience" for more

2. **Enter Your Message**
   - Paste your marketing message, OR
   - Upload a text file

3. **Name Competitors**
   - Add competitor names (e.g., "Microsoft", "Salesforce")
   - Click "+ Add Competitor" for more

4. **Analyze**
   - Click "Analyze Competitor Responses"
   - Wait 10-30 seconds for AI analysis

5. **Review Results**
   - Overall competitive assessment
   - Competitor response strategies
   - Threat levels (Low/Medium/High)
   - Audience reactions
   - Strategic recommendations
   - Potential vulnerabilities

## 🔧 Troubleshooting

### "Unable to create an authenticator"
- Your `.env` file still has placeholder values
- Edit `.env` and add your actual IBM credentials

### "Module not found"
- Run `npm install` in the competitor-analyzer directory

### Port 3000 already in use
- Stop any other Next.js apps running
- Or use: `npm run dev -- -p 3001` (runs on port 3001)

## 📚 Full Documentation

- **README.md** - Complete project documentation
- **SETUP_INSTRUCTIONS.md** - Detailed setup guide

## 🔑 Getting IBM Credentials

1. Go to https://cloud.ibm.com
2. Navigate to your watsonx.ai project
3. Find your API Key and Project ID in project settings

## ✅ Verify Setup

Test your IBM connection:
```bash
# This won't work yet - need to copy test script
# For now, just run npm run dev and try the app
```

## 📊 What You'll Get

For each analysis:
- **Competitor Strategies** - How each competitor will likely respond
- **Counter-Messaging** - Example messages they might use
- **Threat Assessment** - Risk level for each competitor
- **Audience Insights** - How each audience will react
- **Recommendations** - How to strengthen your message
- **Vulnerabilities** - Weak points to address

---

**Ready to start?**
1. `cd competitor-analyzer`
2. `npm install`
3. Edit `.env` with your credentials
4. `npm run dev`
5. Open http://localhost:3000