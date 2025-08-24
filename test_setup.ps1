# Test Setup Script for Auto PDF Converter
# This script helps set up a test environment for the application

Write-Host "Auto PDF Converter - Test Setup Script" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green

# Check if PowerPoint is installed
Write-Host "`nChecking for Microsoft PowerPoint..." -ForegroundColor Yellow

try {
    $powerpoint = New-Object -ComObject PowerPoint.Application
    $powerpoint.Quit()
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($powerpoint) | Out-Null
    Write-Host "✓ Microsoft PowerPoint is installed and accessible" -ForegroundColor Green
} catch {
    Write-Host "✗ Microsoft PowerPoint is not installed or not accessible" -ForegroundColor Red
    Write-Host "  Please install Microsoft PowerPoint to use this application" -ForegroundColor Red
    exit 1
}

# Create test directory
$testDir = Join-Path $env:USERPROFILE "AutoPdfConverterTest"
Write-Host "`nCreating test directory: $testDir" -ForegroundColor Yellow

if (Test-Path $testDir) {
    Write-Host "Test directory already exists" -ForegroundColor Yellow
} else {
    New-Item -ItemType Directory -Path $testDir | Out-Null
    Write-Host "✓ Test directory created" -ForegroundColor Green
}

# Create sample PowerPoint files for testing
Write-Host "`nCreating sample PowerPoint files..." -ForegroundColor Yellow

try {
    $powerpoint = New-Object -ComObject PowerPoint.Application
    $powerpoint.Visible = $false
    
    # Create first test presentation
    $presentation1 = $powerpoint.Presentations.Add()
    $slide1 = $presentation1.Slides.Add(1, 1) # ppLayoutTitle = 1
    $slide1.Shapes.Title.TextFrame.TextRange.Text = "Test Presentation 1"
    $slide1.Shapes.Placeholders[2].TextFrame.TextRange.Text = "This is a test PowerPoint file for Auto PDF Converter"
    
    $testFile1 = Join-Path $testDir "TestPresentation1.pptx"
    $presentation1.SaveAs($testFile1)
    $presentation1.Close()
    Write-Host "✓ Created: TestPresentation1.pptx" -ForegroundColor Green
    
    # Create second test presentation
    $presentation2 = $powerpoint.Presentations.Add()
    $slide2 = $presentation2.Slides.Add(1, 1)
    $slide2.Shapes.Title.TextFrame.TextRange.Text = "Test Presentation 2"
    $slide2.Shapes.Placeholders[2].TextFrame.TextRange.Text = "Another test file with multiple slides"
    
    # Add a second slide
    $slide3 = $presentation2.Slides.Add(2, 2) # ppLayoutText = 2
    $slide3.Shapes.Title.TextFrame.TextRange.Text = "Second Slide"
    $slide3.Shapes.Placeholders[2].TextFrame.TextRange.Text = "This presentation has multiple slides to test conversion"
    
    $testFile2 = Join-Path $testDir "TestPresentation2.pptx"
    $presentation2.SaveAs($testFile2)
    $presentation2.Close()
    Write-Host "✓ Created: TestPresentation2.pptx" -ForegroundColor Green
    
    $powerpoint.Quit()
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($powerpoint) | Out-Null
    
} catch {
    Write-Host "✗ Error creating test PowerPoint files: $($_.Exception.Message)" -ForegroundColor Red
    if ($powerpoint) {
        try { $powerpoint.Quit() } catch {}
    }
}

# Create a batch file for easy testing
$batchContent = @"
@echo off
echo Auto PDF Converter - Quick Test
echo ===============================
echo.
echo Test directory: $testDir
echo.
echo Instructions:
echo 1. Start the Auto PDF Converter application
echo 2. Select the test directory: $testDir
echo 3. Click "Start Monitoring"
echo 4. Copy one of the test PowerPoint files to a new name
echo 5. Watch as it gets converted to PDF automatically
echo.
echo Test files available:
echo - TestPresentation1.pptx
echo - TestPresentation2.pptx
echo.
echo You can copy these files with new names to test the conversion:
echo copy TestPresentation1.pptx NewTest1.pptx
echo copy TestPresentation2.pptx NewTest2.pptx
echo.
pause
"@

$batchFile = Join-Path $testDir "RunTest.bat"
$batchContent | Out-File -FilePath $batchFile -Encoding ASCII
Write-Host "✓ Created test batch file: RunTest.bat" -ForegroundColor Green

# Create a PowerShell test script
$psTestContent = @"
# Quick test script for Auto PDF Converter
Write-Host "Auto PDF Converter - Quick Test" -ForegroundColor Green

`$testDir = "$testDir"
Write-Host "Test directory: `$testDir" -ForegroundColor Yellow

# Function to copy and test a file
function Test-Conversion {
    param([string]`$sourceFile, [string]`$newName)
    
    `$source = Join-Path `$testDir `$sourceFile
    `$destination = Join-Path `$testDir `$newName
    
    if (Test-Path `$source) {
        Copy-Item `$source `$destination
        Write-Host "Copied `$sourceFile to `$newName" -ForegroundColor Green
        Write-Host "Watch for PDF creation..." -ForegroundColor Yellow
        
        # Wait a moment and check for PDF
        Start-Sleep -Seconds 5
        `$pdfFile = `$destination -replace '\.pptx?$', '.pdf'
        if (Test-Path `$pdfFile) {
            Write-Host "✓ PDF created successfully: `$(Split-Path `$pdfFile -Leaf)" -ForegroundColor Green
        } else {
            Write-Host "✗ PDF not found. Check if monitoring is active." -ForegroundColor Red
        }
    } else {
        Write-Host "✗ Source file not found: `$sourceFile" -ForegroundColor Red
    }
}

Write-Host "`nTo test conversion, make sure Auto PDF Converter is running and monitoring this directory."
Write-Host "Then run: Test-Conversion 'TestPresentation1.pptx' 'AutoTest1.pptx'"
Write-Host "Or run: Test-Conversion 'TestPresentation2.pptx' 'AutoTest2.pptx'"
"@

$psTestFile = Join-Path $testDir "QuickTest.ps1"
$psTestContent | Out-File -FilePath $psTestFile -Encoding UTF8
Write-Host "✓ Created PowerShell test script: QuickTest.ps1" -ForegroundColor Green

# Summary
Write-Host "`n" -NoNewline
Write-Host "Setup Complete!" -ForegroundColor Green -BackgroundColor Black
Write-Host "===============" -ForegroundColor Green

Write-Host "`nTest directory created at: $testDir" -ForegroundColor White
Write-Host "`nFiles created:" -ForegroundColor White
Write-Host "  • TestPresentation1.pptx (sample PowerPoint file)" -ForegroundColor Cyan
Write-Host "  • TestPresentation2.pptx (sample PowerPoint file with multiple slides)" -ForegroundColor Cyan
Write-Host "  • RunTest.bat (batch file with test instructions)" -ForegroundColor Cyan
Write-Host "  • QuickTest.ps1 (PowerShell script for automated testing)" -ForegroundColor Cyan

Write-Host "`nNext steps:" -ForegroundColor Yellow
Write-Host "1. Build and run the Auto PDF Converter application" -ForegroundColor White
Write-Host "2. Select the test directory: $testDir" -ForegroundColor White
Write-Host "3. Start monitoring" -ForegroundColor White
Write-Host "4. Copy one of the test files with a new name to trigger conversion" -ForegroundColor White
Write-Host "5. Verify that a PDF file is created automatically" -ForegroundColor White

Write-Host "`nPress any key to open the test directory..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Invoke-Item $testDir
