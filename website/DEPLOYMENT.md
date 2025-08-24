# Deployment Guide

This guide will help you deploy the Auto PDF Converter promotional website to Vercel.

## Prerequisites

- GitHub account
- Vercel account (sign up at [vercel.com](https://vercel.com))
- Domain name (optional, for custom domain)

## Step 1: Prepare the Repository

1. Ensure all website files are in the `website/` folder
2. Commit and push all changes to your GitHub repository

## Step 2: Deploy to Vercel

### Option A: Vercel Dashboard (Recommended)

1. Go to [vercel.com](https://vercel.com) and sign in with your GitHub account
2. Click "Add New..." → "Project"
3. Import your GitHub repository (`wihoho/auto-pdf`)
4. Configure the project:
   - **Framework Preset**: Next.js
   - **Root Directory**: `website`
   - **Build Command**: `npm run build`
   - **Output Directory**: `.next`
   - **Install Command**: `npm install`

5. Click "Deploy"

### Option B: Vercel CLI

```bash
# Install Vercel CLI
npm i -g vercel

# Navigate to website directory
cd website

# Deploy
vercel

# Follow the prompts:
# - Link to existing project? No
# - Project name: auto-pdf-converter
# - Directory: ./
# - Override settings? No
```

## Step 3: Configure Environment Variables

In the Vercel dashboard:

1. Go to your project → Settings → Environment Variables
2. Add the following variables:

```
NEXT_PUBLIC_SITE_URL=https://your-domain.vercel.app
SITE_URL=https://your-domain.vercel.app
NEXT_PUBLIC_GITHUB_REPO=https://github.com/wihoho/auto-pdf
NEXT_PUBLIC_DOWNLOAD_URL=https://github.com/wihoho/auto-pdf/releases/latest
```

## Step 4: Custom Domain (Optional)

1. Purchase a domain from a registrar (Google Domains, Namecheap, etc.)
2. In Vercel dashboard → Project → Settings → Domains
3. Add your custom domain
4. Update your DNS records as instructed by Vercel:
   - Add A record pointing to `76.76.19.61`
   - Or add CNAME record pointing to `cname.vercel-dns.com`

## Step 5: Enable Analytics

1. In Vercel dashboard → Project → Analytics
2. Click "Enable Analytics"
3. Analytics will start collecting data automatically

## Step 6: Verify Deployment

1. Visit your deployed website
2. Check that all sections load correctly
3. Test the download links
4. Verify SEO meta tags using browser dev tools
5. Test geotargeting by using a VPN from different countries

## Automatic Deployments

Once set up, Vercel will automatically:
- Deploy when you push to the `main` branch
- Create preview deployments for pull requests
- Generate sitemaps after each build
- Update the robots.txt file

## Monitoring

- **Analytics**: View traffic and performance in Vercel dashboard
- **Logs**: Check function logs in Vercel dashboard → Functions
- **Performance**: Monitor Core Web Vitals in Analytics tab

## Troubleshooting

### Build Failures
- Check build logs in Vercel dashboard
- Ensure all dependencies are in `package.json`
- Verify environment variables are set correctly

### SEO Issues
- Use Google Search Console to monitor indexing
- Check sitemap at `https://yourdomain.com/sitemap.xml`
- Verify robots.txt at `https://yourdomain.com/robots.txt`

### Geotargeting Not Working
- Test with VPN from different countries
- Check middleware logs in Vercel dashboard
- Verify headers are being set correctly

## Performance Optimization

The website is already optimized with:
- Static generation where possible
- Image optimization
- Edge middleware for geotargeting
- Proper caching headers
- Minified CSS and JavaScript

## Security

Security headers are configured in `vercel.json`:
- Content Security Policy
- X-Frame-Options
- X-Content-Type-Options
- Referrer Policy
