import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

export function middleware(request: NextRequest) {
  // Get the country code from Vercel's geo headers
  const country = (request as any).geo?.country || 'US'
  const city = (request as any).geo?.city || ''
  const region = (request as any).geo?.region || ''

  // Clone the request headers to add geo information
  const requestHeaders = new Headers(request.headers)
  requestHeaders.set('x-geo-country', country)
  requestHeaders.set('x-geo-city', city)
  requestHeaders.set('x-geo-region', region)

  // Continue with the request, passing along the geo information
  return NextResponse.next({
    request: {
      headers: requestHeaders,
    },
  })
}

export const config = {
  matcher: [
    /*
     * Match all request paths except for the ones starting with:
     * - api (API routes)
     * - _next/static (static files)
     * - _next/image (image optimization files)
     * - favicon.ico (favicon file)
     * - sitemap.xml (sitemap)
     * - robots.txt (robots file)
     */
    '/((?!api|_next/static|_next/image|favicon.ico|sitemap.xml|robots.txt).*)',
  ],
}
