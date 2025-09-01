# Auto PDF Converter Website

This is the promotional website for Auto PDF Converter, built with Next.js and deployed on Vercel.

## Features

- **SEO Optimized**: Dynamic meta tags, sitemap generation, and structured data
- **Geotargeting**: Location-based content using Vercel Edge Middleware
- **Performance**: Built with Next.js 15 and Tailwind CSS for optimal performance
- **Analytics**: Integrated with Vercel Analytics for traffic insights
- **Responsive**: Mobile-first design that works on all devices

## Getting Started

1. Install dependencies:
   ```bash
   npm install
   ```

2. Run the development server:
   ```bash
   npm run dev
   ```

3. Open [http://localhost:3000](http://localhost:3000) in your browser.

## Deployment

This website is automatically deployed to Vercel when changes are pushed to the main branch.

### Environment Variables

Copy `.env.example` to `.env.local` and update the values:

```bash
cp .env.example .env.local
```

### Custom Domain Setup

1. In Vercel dashboard, go to your project settings
2. Navigate to the "Domains" tab
3. Add your custom domain
4. Update DNS records as instructed by Vercel

## SEO Features

- Dynamic meta tags for each page
- Open Graph and Twitter Card support
- Automatic sitemap generation
- Robots.txt configuration
- Structured data markup

## Geotargeting

The website uses Vercel's Edge Middleware to detect user location and customize content:

- Currency display based on country
- Location-specific messaging
- Performance optimization for global users

## Analytics

Vercel Analytics is enabled to track:
- Page views and unique visitors
- Performance metrics
- Geographic distribution
- Referral sources

## Tech Stack

- **Framework**: Next.js 15 with App Router
- **Styling**: Tailwind CSS
- **Icons**: Lucide React
- **Deployment**: Vercel
- **Analytics**: Vercel Analytics
- **SEO**: next-sitemap

## Project Structure

```
website/
├── src/
│   └── app/
│       ├── layout.tsx          # Root layout with SEO
│       └── page.tsx            # Landing page
├── public/
│   ├── og-image.svg           # Open Graph image
│   └── ...                    # Static assets
├── middleware.ts              # Geotargeting logic
├── next-sitemap.config.js     # Sitemap configuration
└── package.json
```
