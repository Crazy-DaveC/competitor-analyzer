import { NextRequest, NextResponse } from 'next/server';

interface CompetitorAnalysisRequest {
  message: string;
  audiences: string[];
  competitors: string[];
}

interface CompetitorResponse {
  competitor: string;
  strategy: string;
  counterMessage: string;
  threatLevel: 'Low' | 'Medium' | 'High';
}

interface AudienceReaction {
  audience: string;
  initialReaction: string;
  concerns: string[];
}

interface AnalysisResult {
  overallAssessment: string;
  competitorResponses: CompetitorResponse[];
  audienceReactions: AudienceReaction[];
  recommendations: string[];
  vulnerabilities: string[];
  sources?: string[];
}

// Timeout wrapper function
function withTimeout<T>(promise: Promise<T>, timeoutMs: number): Promise<T> {
  return Promise.race([
    promise,
    new Promise<T>((_, reject) =>
      setTimeout(() => reject(new Error(`Request timed out after ${timeoutMs}ms`)), timeoutMs)
    ),
  ]);
}

export async function POST(req: NextRequest) {
  try {
    const body: CompetitorAnalysisRequest = await req.json();
    const { message, audiences, competitors } = body;

    // Validate inputs
    if (!message || !audiences?.length || !competitors?.length) {
      return NextResponse.json(
        { error: 'Missing required fields: message, audiences, or competitors' },
        { status: 400 }
      );
    }

    // Check for IBM watsonx.ai credentials
    const apiKey = process.env.WATSONX_API_KEY;
    const spaceId = process.env.WATSONX_SPACE_ID;
    const url = process.env.WATSONX_URL || 'https://us-south.ml.cloud.ibm.com';

    console.log('Environment check:', {
      hasApiKey: !!apiKey,
      hasSpaceId: !!spaceId,
      spaceIdValue: spaceId ? `${spaceId.substring(0, 8)}...` : 'undefined',
      url: url
    });

    if (!apiKey || !spaceId) {
      console.error('Missing IBM watsonx.ai credentials', {
        apiKey: apiKey ? 'present' : 'missing',
        spaceId: spaceId ? 'present' : 'missing'
      });
      return NextResponse.json(
        {
          error: 'Server configuration error: Missing AI credentials',
          details: {
            apiKey: apiKey ? 'present' : 'missing',
            spaceId: spaceId ? 'present' : 'missing'
          }
        },
        { status: 500 }
      );
    }

    // Import IBM watsonx.ai SDK
    const { WatsonXAI } = await import('@ibm-cloud/watsonx-ai');
    const { IamAuthenticator } = await import('ibm-cloud-sdk-core');

    // Initialize watsonx client with authentication
    const authenticator = new IamAuthenticator({
      apikey: apiKey,
    });

    const watsonx = WatsonXAI.newInstance({
      version: '2024-05-31',
      serviceUrl: url,
      authenticator: authenticator,
    });

    console.log('WatsonX client initialized successfully');

    // Create the analysis prompt
    const prompt = `You are a competitive intelligence analyst. Analyze the following marketing message and predict how competitors will respond.

Marketing Message:
"${message}"

Target Audiences: ${audiences.join(', ')}
Competitors to Analyze: ${competitors.join(', ')}

Provide a comprehensive analysis in the following JSON format:
{
  "overallAssessment": "Brief overall assessment of the message's competitive positioning",
  "competitorResponses": [
    {
      "competitor": "Competitor Name",
      "strategy": "Their likely response strategy",
      "counterMessage": "Example counter-messaging they might use",
      "threatLevel": "Low/Medium/High"
    }
  ],
  "audienceReactions": [
    {
      "audience": "Audience Name",
      "initialReaction": "How this audience will likely react",
      "concerns": ["concern 1", "concern 2"]
    }
  ],
  "recommendations": ["recommendation 1", "recommendation 2", "recommendation 3"],
  "vulnerabilities": ["vulnerability 1", "vulnerability 2"],
  "sources": ["Source or reference 1 (e.g. competitor website, press release, news article, analyst report)", "Source or reference 2"]
}

Analyze each competitor's likely response based on their known market positioning, strengths, and typical competitive tactics. Consider how each audience segment will perceive the message and potential competitor responses.`;

    // Call IBM Granite LLM
    console.log('Calling watsonx.ai with:', {
      modelId: 'ibm/granite-3-8b-instruct',
      spaceId: spaceId,
      promptLength: prompt.length
    });

    let response;
    try {
      // Wrap the API call with a 30-second timeout
      const requestParams = {
        input: prompt,
        modelId: 'ibm/granite-3-8b-instruct',
        spaceId: spaceId,
        parameters: {
          max_new_tokens: 2000,
          temperature: 0.7,
          top_p: 0.9,
          top_k: 50,
        },
      };

      console.log('Sending request to watsonx.ai with params:', {
        modelId: requestParams.modelId,
        spaceId: requestParams.spaceId,
        inputLength: requestParams.input.length,
        parameters: requestParams.parameters
      });

      response = await withTimeout(
        watsonx.generateText(requestParams),
        30000 // 30 seconds
      );
    } catch (watsonxError: any) {
      console.error('WatsonX API Error Details:', {
        message: watsonxError.message,
        status: watsonxError.status,
        statusText: watsonxError.statusText,
        code: watsonxError.code,
        body: watsonxError.body,
        result: watsonxError.result,
        stack: watsonxError.stack?.split('\n').slice(0, 3).join('\n')
      });
      
      // Check if it was a timeout
      if (watsonxError.message?.includes('timed out')) {
        throw new Error('Request timed out after 30 seconds. The AI service may be slow or unavailable.');
      }
      
      // Provide more specific error messages
      if (watsonxError.message?.includes('space_id') || watsonxError.message?.includes('project_id')) {
        throw new Error(`Space ID validation failed. Please verify the space ID (${spaceId}) exists in your IBM watsonx.ai account and is accessible with your API key.`);
      }
      
      throw new Error(`watsonx API failed: ${watsonxError.message || 'Unknown error'}`);
    }

    console.log('WatsonX response received:', {
      hasResult: !!response.result,
      hasResults: !!response.result?.results,
      resultsLength: response.result?.results?.length
    });

    const generatedText = response.result.results[0].generated_text;

    // Parse the JSON response
    let analysisResult: AnalysisResult;
    try {
      // Try to extract JSON from the response
      const jsonMatch = generatedText.match(/\{[\s\S]*\}/);
      if (jsonMatch) {
        analysisResult = JSON.parse(jsonMatch[0]);
      } else {
        throw new Error('No JSON found in response');
      }
    } catch (parseError) {
      console.error('Failed to parse LLM response:', parseError);
      
      // Fallback: Create a structured response from the text
      analysisResult = {
        overallAssessment: generatedText.substring(0, 300) + '...',
        competitorResponses: competitors.map(comp => ({
          competitor: comp,
          strategy: 'Analysis in progress - please review the full response',
          counterMessage: 'Detailed analysis available in overall assessment',
          threatLevel: 'Medium' as const,
        })),
        audienceReactions: audiences.map(aud => ({
          audience: aud,
          initialReaction: 'Analysis in progress',
          concerns: ['See overall assessment for details'],
        })),
        recommendations: [
          'Review the detailed analysis above',
          'Consider refining message based on competitive landscape',
          'Test message with target audiences',
        ],
        vulnerabilities: [
          'Further analysis needed - see overall assessment',
        ],
      };
    }

    return NextResponse.json(analysisResult);

  } catch (error: any) {
    console.error('Error in competitor analysis:', error);
    
    return NextResponse.json(
      { 
        error: 'Failed to analyze message',
        details: error.message || 'Unknown error occurred'
      },
      { status: 500 }
    );
  }
}

// Made with Bob
