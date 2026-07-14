import { NextRequest, NextResponse } from 'next/server';

const APPID_OAUTH_URL = process.env.APPID_OAUTH_SERVER_URL!;
const CLIENT_ID = process.env.APPID_CLIENT_ID!;
const CLIENT_SECRET = process.env.APPID_SECRET!;
const REDIRECT_URI = process.env.APPID_REDIRECT_URI!;

export async function GET(req: NextRequest) {
  const { searchParams } = req.nextUrl;
  const code = searchParams.get('code');

  // Build the public base URL from headers (works correctly in containers)
  const host = req.headers.get('host') ?? req.nextUrl.host;
  const protocol = req.headers.get('x-forwarded-proto') ?? 'https';
  const appUrl = `${protocol}://${host}`;

  if (!code) {
    return NextResponse.redirect(`${appUrl}/api/auth/login`);
  }

  // Exchange authorization code for tokens
  const tokenRes = await fetch(`${APPID_OAUTH_URL}/token`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'authorization_code',
      code,
      redirect_uri: REDIRECT_URI,
      client_id: CLIENT_ID,
      client_secret: CLIENT_SECRET,
    }),
  });

  if (!tokenRes.ok) {
    const err = await tokenRes.text();
    console.error('App ID token exchange failed:', err);
    return NextResponse.redirect(`${appUrl}/api/auth/login`);
  }

  const tokens = await tokenRes.json();

  // Set a session cookie containing the access token
  // HttpOnly + Secure so JS can't access it
  const response = NextResponse.redirect(appUrl);
  response.cookies.set('appid_session', tokens.access_token, {
    httpOnly: true,
    secure: true,
    sameSite: 'lax',
    // Expire when the access token expires (or 8 hours max)
    maxAge: Math.min(tokens.expires_in ?? 3600, 28800),
    path: '/',
  });

  return response;
}
