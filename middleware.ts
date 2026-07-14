import { NextRequest, NextResponse } from 'next/server';

// Paths that don't require authentication
const PUBLIC_PATHS = ['/api/auth/login', '/api/auth/callback', '/api/auth/logout', '/ibm-logo.svg'];

export function middleware(req: NextRequest) {
  const { pathname } = req.nextUrl;

  // Allow public auth paths through
  if (PUBLIC_PATHS.some((p) => pathname.startsWith(p))) {
    return NextResponse.next();
  }

  // Check for session cookie
  const session = req.cookies.get('appid_session');
  if (!session?.value) {
    // Build the public-facing URL using the Host header (avoids 0.0.0.0 in containers)
    const host = req.headers.get('host') ?? req.nextUrl.host;
    const protocol = req.headers.get('x-forwarded-proto') ?? 'https';
    const publicUrl = `${protocol}://${host}${pathname}`;

    const loginUrl = new URL('/api/auth/login', `${protocol}://${host}`);
    loginUrl.searchParams.set('redirect', publicUrl);
    return NextResponse.redirect(loginUrl);
  }

  return NextResponse.next();
}

export const config = {
  // Apply to all routes except static assets and Next.js internals
  matcher: ['/((?!_next/static|_next/image|favicon.ico).*)'],
};
