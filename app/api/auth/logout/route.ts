import { NextRequest, NextResponse } from 'next/server';

export async function GET(req: NextRequest) {
  // Clear the session cookie and redirect to login
  const host = req.headers.get('host') ?? req.nextUrl.host;
  const protocol = req.headers.get('x-forwarded-proto') ?? 'https';
  const loginUrl = `${protocol}://${host}/api/auth/login`;

  const response = NextResponse.redirect(loginUrl);
  response.cookies.set('appid_session', '', { maxAge: 0, path: '/' });
  return response;
}
