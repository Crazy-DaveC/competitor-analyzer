# Competitor Response Analyzer

A powerful marketing tool that uses IBM watsonx.ai to predict how competitors will respond to your messaging content. Built with Next.js and IBM Granite LLM.

## 🎯 Overview

This application helps marketing teams:
- **Test messaging** before going to market
- **Predict competitor responses** using AI analysis
- **Understand audience reactions** across different segments
- **Identify vulnerabilities** in messaging strategy
- **Get strategic recommendations** to strengthen positioning

## ✨ Features

### 1. Multi-Audience Analysis
- Define multiple target audiences (CIOs, Marketing Directors, etc.)
- Get tailored reactions for each audience segment
- Understand specific concerns per audience

### 2. Competitor Intelligence
- Analyze multiple competitors simultaneously
- Predict their response strategies
- See example counter-messaging they might use
- Get threat level assessments (Low/Medium/High)

### 3. Strategic Insights
- Overall competitive positioning assessment
- Actionable recommendations to improve messaging
- Vulnerability identification
- Evidence-based analysis using IBM Granite LLM

### 4. Flexible Input
- Paste messages directly
- Upload text files
- Support for various message formats

## 🚀 Quick Start

### Prerequisites
- Node.js 18+ installed
- IBM Cloud account with watsonx.ai access
- IBM watsonx.ai API key and Project ID

### Installation

1. **Clone or navigate to the project directory**
```bash
cd "c:/Users/DavidChamak/Documents/$user/market insights/IBM Bob Experiments"
```

2. **Dependencies are already installed** (npm install was run)

3. **Configure your IBM credentials**
Edit `.env.local` and add your credentials:
```env
WATSONX_API_KEY=your_actual_api_key
WATSONX_PROJECT_ID=your_actual_project_id
WATSONX_URL=https://us-south.ml.cloud.ibm.com
```

4. **Test your connection**
```bash
npm run test-llm
```

5. **Start the development server**
```bash
npm run dev
```

6. **Open your browser**
Navigate to `http://localhost:3000`

## 📖 How to Use

### Step 1: Define Target Audiences
- Enter one or more target audiences
- Examples: "CIOs", "Marketing Directors", "IT Managers"
- Click "+ Add Audience" for multiple audiences

### Step 2: Enter Your Message
- Paste your marketing message in the text area, OR
- Click "📎 Upload File" to upload a text file

### Step 3: Name Competitors
- Enter competitor names
- Examples: "Microsoft", "Salesforce", "Oracle"
- Click "+ Add Competitor" for multiple competitors

### Step 4: Analyze
- Click "Analyze Competitor Responses"
- Wait 10-30 seconds for AI analysis

### Step 5: Review Results
The analysis provides:
- **Overall Assessment**: High-level competitive positioning summary
- **Competitor Responses**: Strategy, counter-messaging, and threat level for each competitor
- **Audience Reactions**: Initial reactions and concerns for each audience
- **Strategic Recommendations**: Actionable advice to improve your message
- **Potential Vulnerabilities**: Areas where competitors might attack

## 🏗️ Project Structure

```
├── app/
│   ├── page.tsx                          # Main UI component
│   └── api/
│       └── competitor-analysis/
│           └── route.ts                  # API endpoint
├── scripts/
│   ├── test-llm-connection.ts           # Test IBM connection
│   └── test-vector-db.ts                # Test vector DB (optional)
├── .env.local                            # Environment variables
├── package.json                          # Dependencies
├── tsconfig.json                         # TypeScript config
├── next.config.js                        # Next.js config
├── SETUP_INSTRUCTIONS.md                 # Detailed setup guide
└── README.md                             # This file
```

## 🔧 Configuration Files Created

The following files have been created for you:

1. **tsconfig.json** - TypeScript configuration
2. **next.config.js** - Next.js configuration
3. **.env.local** - Environment variables (needs your credentials)
4. **app/page.tsx** - Frontend UI component
5. **app/api/competitor-analysis/route.ts** - Backend API endpoint

## 🎨 UI Components

### Input Section
- Dynamic audience input fields
- Message text area with file upload
- Dynamic competitor input fields
- Validation and error handling

### Results Section
- Overall assessment card
- Competitor response cards with threat levels
- Audience reaction cards
- Strategic recommendations panel
- Vulnerabilities alert panel

## 🔐 Security Notes

- Never commit `.env.local` to version control (already in .gitignore)
- Keep your IBM API keys secure
- The `.env.local` file contains placeholder values - replace with real credentials

## 🛠️ Troubleshooting

### TypeScript Errors
The TypeScript configuration is set up correctly. If you see errors:
1. Restart your IDE/editor
2. Run `npm install` again
3. Check that all config files are present

### API Connection Issues
If analysis fails:
1. Verify credentials in `.env.local`
2. Run `npm run test-llm` to test connection
3. Check browser console for errors
4. Ensure IBM Cloud account has watsonx.ai access

### Module Not Found Errors
All dependencies should be installed. If issues persist:
```bash
npm install next react react-dom @ibm-cloud/watsonx-ai
npm install --save-dev @types/node @types/react @types/react-dom typescript
```

## 📊 Example Use Cases

### 1. Product Launch
Test messaging for a new product launch against key competitors to identify potential counter-attacks.

### 2. Campaign Planning
Evaluate campaign messaging across different audience segments before committing budget.

### 3. Competitive Positioning
Understand how your positioning will be perceived relative to competitors.

### 4. Message Refinement
Iterate on messaging by testing multiple variations and comparing results.

## 🚀 Future Enhancements

Potential improvements:
- Historical analysis tracking
- A/B testing multiple message variations
- Industry-specific competitor templates
- PDF/PowerPoint report generation
- Team collaboration features
- Real-time competitor monitoring
- Marketing automation platform integration

## 📝 Technical Details

### Frontend
- **Framework**: Next.js 14 with React 18
- **Styling**: Inline styles (IBM-inspired dark theme)
- **State Management**: React hooks (useState)

### Backend
- **API**: Next.js API routes
- **AI Model**: IBM watsonx.ai Granite 13B Chat v2
- **Response Format**: Structured JSON with comprehensive analysis

### AI Prompt Engineering
The system uses a carefully crafted prompt that:
- Provides context about the message and audiences
- Requests structured JSON output
- Asks for specific analysis dimensions
- Considers competitive positioning and tactics

## 📄 License

This project is for internal use within your organization.

## 🤝 Support

For issues or questions:
1. Check SETUP_INSTRUCTIONS.md for detailed guidance
2. Review IBM watsonx.ai documentation
3. Verify environment variables are set correctly
4. Check browser console and server logs for errors

## 🎯 Next Steps

1. **Add your IBM credentials** to `.env.local`
2. **Test the connection** with `npm run test-llm`
3. **Start the server** with `npm run dev`
4. **Try your first analysis** at `http://localhost:3000`

---

Built with IBM watsonx.ai and Next.js