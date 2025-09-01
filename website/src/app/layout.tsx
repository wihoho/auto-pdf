import type { Metadata } from "next";
import { Geist, Geist_Mono } from "next/font/google";
import { Analytics } from '@vercel/analytics/react';
import "./globals.css";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: "Auto PDF Converter | Automatic PowerPoint to PDF Conversion",
  description: "Automatically convert PowerPoint files (.ppt, .pptx) to PDF format when added to a monitored folder. Fast, reliable, and user-friendly Windows desktop application.",
  keywords: ["PowerPoint to PDF", "PPT converter", "PPTX to PDF", "automatic conversion", "Windows desktop app", "file monitoring"],
  authors: [{ name: "Auto PDF Converter Team" }],
  creator: "Auto PDF Converter",
  publisher: "Auto PDF Converter",
  formatDetection: {
    email: false,
    address: false,
    telephone: false,
  },
  metadataBase: new URL(process.env.NEXT_PUBLIC_SITE_URL || 'https://auto-pdf-converter.vercel.app'),
  alternates: {
    canonical: '/',
  },
  openGraph: {
    title: "Auto PDF Converter | Automatic PowerPoint to PDF Conversion",
    description: "Automatically convert PowerPoint files (.ppt, .pptx) to PDF format when added to a monitored folder. Fast, reliable, and user-friendly Windows desktop application.",
    url: '/',
    siteName: 'Auto PDF Converter',
    images: [
      {
        url: '/og-image.png',
        width: 1200,
        height: 630,
        alt: 'Auto PDF Converter - Automatic PowerPoint to PDF Conversion',
      },
    ],
    locale: 'en_US',
    type: 'website',
  },
  twitter: {
    card: 'summary_large_image',
    title: "Auto PDF Converter | Automatic PowerPoint to PDF Conversion",
    description: "Automatically convert PowerPoint files (.ppt, .pptx) to PDF format when added to a monitored folder.",
    images: ['/og-image.png'],
  },
  robots: {
    index: true,
    follow: true,
    googleBot: {
      index: true,
      follow: true,
      'max-video-preview': -1,
      'max-image-preview': 'large',
      'max-snippet': -1,
    },
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body
        className={`${geistSans.variable} ${geistMono.variable} antialiased`}
      >
        {children}
        <Analytics />
      </body>
    </html>
  );
}
