import { NextRequest, NextResponse } from 'next/server';

const APPID_OAUTH_URL = process.env.APPID_OAUTH_SERVER_URL!;
const CLIENT_ID = process.env.APPID_CLIENT_ID!;
const REDIRECT_URI = process.env.APPID_REDIRECT_URI!;

export async function GET(req: NextRequest) {
  const { searchParams } = req.nextUrl;
  const redirect = searchParams.get('redirect') || '/';

  // Build the App ID authorization URL
  const authUrl = new URL(`${APPID_OAUTH_URL}/authorization`);
  authUrl.searchParams.set('response_type', 'code');
  authUrl.searchParams.set('client_id', CLIENT_ID);
  authUrl.searchParams.set('redirect_uri', REDIRECT_URI);
  authUrl.searchParams.set('scope', 'openid profile email');
  // Store the intended destination in the state param
  authUrl.searchParams.set('state', encodeURIComponent(redirect));

  return NextResponse.redirect(authUrl.toString());
}
