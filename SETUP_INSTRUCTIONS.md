# Competitor Response Analyzer - Setup Instructions

## Overview
This application allows marketing users to test how competitors might react to specific messaging content. It uses IBM watsonx.ai's Granite LLM to analyze messages and predict competitor responses.

## What Has Been Built

### 1. Frontend UI (`app/page.tsx`)
A comprehensive React interface with:
- **Audience Input**: Dynamic form to add/remove multiple target audiences
- **Message Input**: Text area for pasting messages or file upload capability
- **Competitor Input**: Dynamic form to add/remove multiple competitors
- **Results Display**: Detailed analysis showing:
  - Overall assessment
  - Predicted competitor responses with threat levels
  - Audience reactions and concerns
  - Strategic recommendations
  - Potential vulnerabilities

### 2. Backend API (`app/api/competitor-analysis/route.ts`)
A Next.js API route that:
- Accepts message, audiences, and competitors
- Connects to IBM watsonx.ai Granite LLM
- Generates comprehensive competitive analysis
- Returns structured JSON with predictions and insights

## Setup Steps

### Step 1: Install Dependencies
The project already has most dependencies in `package.json`. You need to install them:

```bash
npm install
```

### Step 2: Configure Environment Variables
Create a `.env.local` file in the root directory with your IBM watsonx.ai credentials:

```env
# IBM watsonx.ai Configuration
WATSONX_API_KEY=your_watsonx_api_key_here
WATSONX_PROJECT_ID=your_project_id_here
WATSONX_URL=https://us-south.ml.cloud.ibm.com

# Optional: Vector Database (if needed for future enhancements)
PINECONE_API_KEY=your_pinecone_api_key_here
PINECONE_ENVIRONMENT=your_pinecone_environment_here
PINECONE_INDEX_NAME=mmapi-documents

# Optional: Embeddings
OPENAI_API_KEY=your_openai_api_key_here
```

### Step 3: Create TypeScript Configuration
Create a `tsconfig.json` file in the root directory:

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "jsx": "preserve",
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "allowJs": true,
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "incremental": true,
    "plugins": [
      {
        "name": "next"
      }
    ],
    "paths": {
      "@/*": ["./*"]
    }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
```

### Step 4: Create Next.js Configuration
Create a `next.config.js` file in the root directory:

```javascript
/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  swcMinify: true,
}

module.exports = nextConfig
```

### Step 5: Test IBM watsonx.ai Connection
Before running the app, test your IBM credentials:

```bash
npm run test-llm
```

This will verify your watsonx.ai connection is working properly.

### Step 6: Run the Development Server
Start the Next.js development server:

```bash
npm run dev
```

The application will be available at `http://localhost:3000`

## How to Use the Application

### 1. Define Target Audiences
- Enter one or more target audiences (e.g., "CIOs", "Marketing Directors", "IT Managers")
- Click "+ Add Audience" to add more audiences
- Click "Remove" to delete an audience

### 2. Enter Your Message
- Paste your marketing message in the text area, OR
- Click "📎 Upload File" to upload a text file containing your message

### 3. Name Competitors
- Enter competitor names (e.g., "Microsoft", "Salesforce", "Oracle")
- Click "+ Add Competitor" to add more competitors
- Click "Remove" to delete a competitor

### 4. Analyze
- Click "Analyze Competitor Responses" button
- Wait for the AI analysis (typically 10-30 seconds)

### 5. Review Results
The analysis will show:
- **Overall Assessment**: High-level summary of competitive positioning
- **Competitor Responses**: For each competitor:
  - Likely response strategy
  - Example counter-messaging
  - Threat level (Low/Medium/High)
- **Audience Reactions**: For each audience:
  - Initial reaction to your message
  - Key concerns they might have
- **Strategic Recommendations**: Actionable advice for improving your message
- **Potential Vulnerabilities**: Areas where competitors might attack

## Architecture

```
app/
├── page.tsx                          # Main UI component
└── api/
    └── competitor-analysis/
        └── route.ts                  # API endpoint for analysis

scripts/
├── test-llm-connection.ts           # Test IBM watsonx.ai connection
└── test-vector-db.ts                # Test vector database (optional)

.env.local                            # Environment variables (create this)
package.json                          # Dependencies
tsconfig.json                         # TypeScript config (create this)
next.config.js                        # Next.js config (create this)
```

## Key Features

1. **Multi-Audience Analysis**: Analyze how different audience segments will react
2. **Multi-Competitor Analysis**: Get predictions for multiple competitors at once
3. **File Upload Support**: Upload message files instead of pasting
4. **Threat Level Assessment**: Understand which competitor responses pose the highest risk
5. **Strategic Recommendations**: Get actionable advice to strengthen your message
6. **Vulnerability Detection**: Identify weak points in your messaging

## Troubleshooting

### TypeScript Errors
If you see TypeScript errors, ensure:
1. `tsconfig.json` is created with the configuration above
2. Run `npm install` to ensure all type definitions are installed
3. Restart your IDE/editor

### API Connection Issues
If the analysis fails:
1. Verify your `.env.local` file has correct credentials
2. Run `npm run test-llm` to test the connection
3. Check the browser console for detailed error messages
4. Ensure your IBM Cloud account has access to watsonx.ai

### Missing Dependencies
If you get module not found errors:
```bash
npm install next react react-dom @ibm-cloud/watsonx-ai
npm install --save-dev @types/node @types/react @types/react-dom typescript
```

## Future Enhancements

Potential improvements for this tool:
1. **Historical Analysis**: Store and compare analyses over time
2. **A/B Testing**: Compare multiple message variations
3. **Industry Templates**: Pre-built competitor profiles by industry
4. **Export Reports**: Generate PDF/PowerPoint reports
5. **Collaboration**: Share analyses with team members
6. **Real-time Monitoring**: Track actual competitor responses
7. **Integration**: Connect with marketing automation platforms

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review IBM watsonx.ai documentation
3. Verify all environment variables are set correctly
4. Check the browser console and server logs for errors