import { headers } from 'next/headers';
import { Download, FileText, FolderOpen, Zap, Shield, Clock, CheckCircle, HelpCircle } from 'lucide-react';

export default async function Home() {
  const headersList = await headers();
  const country = headersList.get('x-geo-country') || 'US';
  
  // Determine currency and download links based on location
  const currency = country === 'US' ? '$' : country === 'GB' ? '£' : '€';
  const downloadUrl = 'https://github.com/wihoho/auto-pdf/releases/latest';

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100">
      {/* Header */}
      <header className="bg-white shadow-sm">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex justify-between items-center">
            <div className="flex items-center space-x-2">
              <FileText className="h-8 w-8 text-blue-600" />
              <span className="text-xl font-bold text-gray-900">Auto PDF Converter</span>
            </div>
            <nav className="hidden md:flex space-x-8">
              <a href="#features" className="text-gray-600 hover:text-blue-600 transition-colors">Features</a>
              <a href="#how-it-works" className="text-gray-600 hover:text-blue-600 transition-colors">How It Works</a>
              <a href="#faq" className="text-gray-600 hover:text-blue-600 transition-colors">FAQ</a>
            </nav>
          </div>
        </div>
      </header>

      {/* Hero Section */}
      <section className="py-20 px-4 sm:px-6 lg:px-8">
        <div className="max-w-4xl mx-auto text-center">
          <h1 className="text-4xl md:text-6xl font-bold text-gray-900 mb-6">
            Convert PowerPoint to PDF
            <span className="text-blue-600 block">Automatically</span>
          </h1>
          <p className="text-xl text-gray-600 mb-8 max-w-2xl mx-auto">
            Monitor any folder and instantly convert PowerPoint files (.ppt, .pptx) to PDF format. 
            No manual work required - just drop files and watch them convert.
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <a
              href={downloadUrl}
              className="inline-flex items-center px-8 py-4 bg-blue-600 text-white font-semibold rounded-lg hover:bg-blue-700 transition-colors shadow-lg"
            >
              <Download className="mr-2 h-5 w-5" />
              Download for Windows
            </a>
            <a
              href="#how-it-works"
              className="inline-flex items-center px-8 py-4 bg-white text-blue-600 font-semibold rounded-lg border-2 border-blue-600 hover:bg-blue-50 transition-colors"
            >
              Learn More
            </a>
          </div>
          <p className="text-sm text-gray-500 mt-4">
            Free to download • Windows 10+ • Requires Microsoft PowerPoint
          </p>
        </div>
      </section>

      {/* Features Section */}
      <section id="features" className="py-20 bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-16">
            <h2 className="text-3xl md:text-4xl font-bold text-gray-900 mb-4">
              Why Choose Auto PDF Converter?
            </h2>
            <p className="text-xl text-gray-600 max-w-2xl mx-auto">
              Built for professionals who need reliable, automated document conversion
            </p>
          </div>
          
          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
            <div className="text-center p-6">
              <div className="bg-blue-100 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-4">
                <FolderOpen className="h-8 w-8 text-blue-600" />
              </div>
              <h3 className="text-xl font-semibold text-gray-900 mb-2">Automatic Monitoring</h3>
              <p className="text-gray-600">
                Select any folder and the app will watch for new PowerPoint files automatically
              </p>
            </div>
            
            <div className="text-center p-6">
              <div className="bg-green-100 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-4">
                <Zap className="h-8 w-8 text-green-600" />
              </div>
              <h3 className="text-xl font-semibold text-gray-900 mb-2">Instant Conversion</h3>
              <p className="text-gray-600">
                Files are converted to PDF immediately when detected, using Microsoft PowerPoint
              </p>
            </div>
            
            <div className="text-center p-6">
              <div className="bg-purple-100 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-4">
                <Shield className="h-8 w-8 text-purple-600" />
              </div>
              <h3 className="text-xl font-semibold text-gray-900 mb-2">Reliable & Safe</h3>
              <p className="text-gray-600">
                Uses PowerPoint&apos;s native export functionality for perfect formatting preservation
              </p>
            </div>
            
            <div className="text-center p-6">
              <div className="bg-orange-100 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-4">
                <Clock className="h-8 w-8 text-orange-600" />
              </div>
              <h3 className="text-xl font-semibold text-gray-900 mb-2">Background Operation</h3>
              <p className="text-gray-600">
                Runs quietly in the background without interrupting your workflow
              </p>
            </div>
            
            <div className="text-center p-6">
              <div className="bg-red-100 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-4">
                <FileText className="h-8 w-8 text-red-600" />
              </div>
              <h3 className="text-xl font-semibold text-gray-900 mb-2">Activity Logging</h3>
              <p className="text-gray-600">
                Comprehensive logging of all conversions and detailed error messages
              </p>
            </div>
            
            <div className="text-center p-6">
              <div className="bg-indigo-100 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-4">
                <CheckCircle className="h-8 w-8 text-indigo-600" />
              </div>
              <h3 className="text-xl font-semibold text-gray-900 mb-2">User-Friendly</h3>
              <p className="text-gray-600">
                Simple interface with real-time status updates and easy folder selection
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* How It Works Section */}
      <section id="how-it-works" className="py-20 bg-gray-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-16">
            <h2 className="text-3xl md:text-4xl font-bold text-gray-900 mb-4">
              How It Works
            </h2>
            <p className="text-xl text-gray-600 max-w-2xl mx-auto">
              Get started in just 3 simple steps
            </p>
          </div>

          <div className="grid md:grid-cols-3 gap-8">
            <div className="text-center">
              <div className="bg-blue-600 text-white w-12 h-12 rounded-full flex items-center justify-center mx-auto mb-4 text-xl font-bold">
                1
              </div>
              <h3 className="text-xl font-semibold text-gray-900 mb-2">Select Folder</h3>
              <p className="text-gray-600">
                Choose any folder on your computer that you want to monitor for PowerPoint files
              </p>
            </div>

            <div className="text-center">
              <div className="bg-blue-600 text-white w-12 h-12 rounded-full flex items-center justify-center mx-auto mb-4 text-xl font-bold">
                2
              </div>
              <h3 className="text-xl font-semibold text-gray-900 mb-2">Start Monitoring</h3>
              <p className="text-gray-600">
                Click &ldquo;Start Monitoring&rdquo; and the app will watch for new .ppt and .pptx files
              </p>
            </div>

            <div className="text-center">
              <div className="bg-blue-600 text-white w-12 h-12 rounded-full flex items-center justify-center mx-auto mb-4 text-xl font-bold">
                3
              </div>
              <h3 className="text-xl font-semibold text-gray-900 mb-2">Automatic Conversion</h3>
              <p className="text-gray-600">
                Drop PowerPoint files into the folder and they&apos;ll be instantly converted to PDF
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* FAQ Section */}
      <section id="faq" className="py-20 bg-white">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-16">
            <h2 className="text-3xl md:text-4xl font-bold text-gray-900 mb-4">
              Frequently Asked Questions
            </h2>
          </div>

          <div className="space-y-8">
            <div className="border-b border-gray-200 pb-8">
              <div className="flex items-start space-x-4">
                <HelpCircle className="h-6 w-6 text-blue-600 mt-1 flex-shrink-0" />
                <div>
                  <h3 className="text-lg font-semibold text-gray-900 mb-2">
                    Do I need Microsoft PowerPoint installed?
                  </h3>
                  <p className="text-gray-600">
                    Yes, Microsoft PowerPoint must be installed on your system. The app uses PowerPoint&apos;s native conversion engine to ensure perfect formatting and compatibility.
                  </p>
                </div>
              </div>
            </div>

            <div className="border-b border-gray-200 pb-8">
              <div className="flex items-start space-x-4">
                <HelpCircle className="h-6 w-6 text-blue-600 mt-1 flex-shrink-0" />
                <div>
                  <h3 className="text-lg font-semibold text-gray-900 mb-2">
                    What file formats are supported?
                  </h3>
                  <p className="text-gray-600">
                    The app supports both .ppt (PowerPoint 97-2003) and .pptx (PowerPoint 2007+) formats, including macro-enabled .pptm files.
                  </p>
                </div>
              </div>
            </div>

            <div className="border-b border-gray-200 pb-8">
              <div className="flex items-start space-x-4">
                <HelpCircle className="h-6 w-6 text-blue-600 mt-1 flex-shrink-0" />
                <div>
                  <h3 className="text-lg font-semibold text-gray-900 mb-2">
                    Is it free to use?
                  </h3>
                  <p className="text-gray-600">
                    Yes, Auto PDF Converter is completely free to download and use. No subscriptions, no hidden fees.
                  </p>
                </div>
              </div>
            </div>

            <div className="border-b border-gray-200 pb-8">
              <div className="flex items-start space-x-4">
                <HelpCircle className="h-6 w-6 text-blue-600 mt-1 flex-shrink-0" />
                <div>
                  <h3 className="text-lg font-semibold text-gray-900 mb-2">
                    Can I monitor multiple folders?
                  </h3>
                  <p className="text-gray-600">
                    Currently, the app monitors one folder at a time. You can easily switch between different folders as needed.
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-20 bg-blue-600">
        <div className="max-w-4xl mx-auto text-center px-4 sm:px-6 lg:px-8">
          <h2 className="text-3xl md:text-4xl font-bold text-white mb-4">
            Ready to Automate Your Workflow?
          </h2>
          <p className="text-xl text-blue-100 mb-8 max-w-2xl mx-auto">
            Download Auto PDF Converter now and never manually convert PowerPoint files again.
          </p>
          <a
            href={downloadUrl}
            className="inline-flex items-center px-8 py-4 bg-white text-blue-600 font-semibold rounded-lg hover:bg-gray-100 transition-colors shadow-lg"
          >
            <Download className="mr-2 h-5 w-5" />
            Download for Windows
          </a>
          <p className="text-sm text-blue-200 mt-4">
            Compatible with Windows 10 and later
          </p>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-gray-900 text-white py-12">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid md:grid-cols-4 gap-8">
            <div className="md:col-span-2">
              <div className="flex items-center space-x-2 mb-4">
                <FileText className="h-8 w-8 text-blue-400" />
                <span className="text-xl font-bold">Auto PDF Converter</span>
              </div>
              <p className="text-gray-400 mb-4">
                Automatically convert PowerPoint files to PDF format with our reliable Windows desktop application.
              </p>
              <p className="text-sm text-gray-500">
                Detected location: {country} • Currency: {currency}
              </p>
            </div>

            <div>
              <h3 className="text-lg font-semibold mb-4">Product</h3>
              <ul className="space-y-2 text-gray-400">
                <li><a href="#features" className="hover:text-white transition-colors">Features</a></li>
                <li><a href="#how-it-works" className="hover:text-white transition-colors">How It Works</a></li>
                <li><a href={downloadUrl} className="hover:text-white transition-colors">Download</a></li>
              </ul>
            </div>

            <div>
              <h3 className="text-lg font-semibold mb-4">Support</h3>
              <ul className="space-y-2 text-gray-400">
                <li><a href="#faq" className="hover:text-white transition-colors">FAQ</a></li>
                <li><a href="https://github.com/wihoho/auto-pdf/issues" className="hover:text-white transition-colors">Report Issues</a></li>
                <li><a href="https://github.com/wihoho/auto-pdf" className="hover:text-white transition-colors">Source Code</a></li>
              </ul>
            </div>
          </div>

          <div className="border-t border-gray-800 mt-8 pt-8 text-center text-gray-400">
            <p>&copy; 2024 Auto PDF Converter. Built with ❤️ for productivity.</p>
          </div>
        </div>
      </footer>
    </div>
  );
}
