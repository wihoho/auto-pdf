# Test the enhanced PowerShell logging script
param(
    [string]$InputFile = "C:\Users\wihoh\Downloads\ppt\test-presentation-20250824-171947.pptx",
    [string]$OutputFile = "C:\Users\wihoh\Downloads\ppt\test-enhanced-logging.pdf"
)

# ===== PowerPoint to PDF Conversion Script =====
Write-Host "=== CONVERSION SCRIPT START ==="
Write-Host "Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Host "PowerShell Version: $($PSVersionTable.PSVersion)"
Write-Host "Input File: $InputFile"
Write-Host "Output File: $OutputFile"
Write-Host ""

try {
    # Step 1: Validate input file
    Write-Host "STEP 1: Validating input file..."
    if (-not (Test-Path $InputFile)) {
        throw "Input file does not exist: $InputFile"
    }
    
    $inputFileObj = Get-Item $InputFile
    Write-Host "  ✓ Input file exists"
    Write-Host "  - Full path: $($inputFileObj.FullName)"
    Write-Host "  - Size: $($inputFileObj.Length) bytes"
    Write-Host "  - Last modified: $($inputFileObj.LastWriteTime)"
    Write-Host "  - Extension: $($inputFileObj.Extension)"
    
    # Step 2: Check output directory
    Write-Host ""
    Write-Host "STEP 2: Checking output directory..."
    $outputDir = Split-Path $OutputFile -Parent
    if (-not (Test-Path $outputDir)) {
        throw "Output directory does not exist: $outputDir"
    }
    Write-Host "  ✓ Output directory exists: $outputDir"
    
    # Step 3: Test PowerPoint COM availability
    Write-Host ""
    Write-Host "STEP 3: Testing PowerPoint COM availability..."
    try {
        $testPpt = New-Object -ComObject PowerPoint.Application
        $testPpt.Quit()
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($testPpt) | Out-Null
        Write-Host "  ✓ PowerPoint COM object accessible"
    } catch {
        throw "PowerPoint COM object not available: $($_.Exception.Message)"
    }
    
    # Step 4: Create PowerPoint application
    Write-Host ""
    Write-Host "STEP 4: Creating PowerPoint application..."
    $powerpoint = New-Object -ComObject PowerPoint.Application
    Write-Host "  ✓ PowerPoint application created"
    Write-Host "  - Version: $($powerpoint.Version)"
    Write-Host "  - Build: $($powerpoint.Build)"
    
    $powerpoint.Visible = $false
    Write-Host "  ✓ PowerPoint set to invisible mode"
    
    # Step 5: Open presentation
    Write-Host ""
    Write-Host "STEP 5: Opening presentation..."
    Write-Host "  - Opening file: $InputFile"
    $presentation = $powerpoint.Presentations.Open($InputFile, $true, $true, $false)
    Write-Host "  ✓ Presentation opened successfully"
    Write-Host "  - Slide count: $($presentation.Slides.Count)"
    Write-Host "  - Name: $($presentation.Name)"
    
    # Step 6: Export as PDF
    Write-Host ""
    Write-Host "STEP 6: Exporting as PDF..."
    Write-Host "  - Target path: $OutputFile"
    Write-Host "  - Format: PDF (ppSaveAsPDF = 32)"
    
    $exportStart = Get-Date
    $presentation.ExportAsFixedFormat($OutputFile, 32)
    $exportDuration = (Get-Date) - $exportStart
    
    Write-Host "  ✓ Export completed in $($exportDuration.TotalSeconds) seconds"
    
    # Step 7: Close presentation
    Write-Host ""
    Write-Host "STEP 7: Closing presentation..."
    $presentation.Close()
    Write-Host "  ✓ Presentation closed"
    
    # Step 8: Quit PowerPoint
    Write-Host ""
    Write-Host "STEP 8: Quitting PowerPoint..."
    $powerpoint.Quit()
    Write-Host "  ✓ PowerPoint quit successfully"
    
    # Step 9: Release COM objects
    Write-Host ""
    Write-Host "STEP 9: Releasing COM objects..."
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($presentation) | Out-Null
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($powerpoint) | Out-Null
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
    Write-Host "  ✓ COM objects released and garbage collected"
    
    # Step 10: Verify PDF creation
    Write-Host ""
    Write-Host "STEP 10: Verifying PDF creation..."
    if (Test-Path $OutputFile) {
        $pdfFile = Get-Item $OutputFile
        Write-Host "  ✓ PDF file created successfully"
        Write-Host "  - Path: $($pdfFile.FullName)"
        Write-Host "  - Size: $($pdfFile.Length) bytes"
        Write-Host "  - Created: $($pdfFile.CreationTime)"
        
        Write-Host ""
        Write-Host "=== CONVERSION SUCCESS ==="
        Write-Host "Completed at: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
        exit 0
    } else {
        throw "PDF file was not created at expected location: $OutputFile"
    }
}
catch {
    Write-Host ""
    Write-Host "=== CONVERSION FAILED ==="
    Write-Host "Error occurred at: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    Write-Host "Error Message: $($_.Exception.Message)"
    Write-Host "Error Type: $($_.Exception.GetType().Name)"
    Write-Host "Error Category: $($_.CategoryInfo.Category)"
    
    if ($_.Exception.InnerException) {
        Write-Host "Inner Exception: $($_.Exception.InnerException.Message)"
    }
    
    Write-Host "Stack Trace:"
    Write-Host $_.ScriptStackTrace
    
    # Cleanup in case of error
    Write-Host ""
    Write-Host "Performing cleanup..."
    try {
        if ($presentation) { 
            Write-Host "  - Closing presentation..."
            $presentation.Close() 
            Write-Host "  ✓ Presentation closed"
        }
        if ($powerpoint) { 
            Write-Host "  - Quitting PowerPoint..."
            $powerpoint.Quit() 
            Write-Host "  ✓ PowerPoint quit"
        }
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($presentation) | Out-Null
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($powerpoint) | Out-Null
        Write-Host "  ✓ COM objects released"
    } catch {
        Write-Host "  ! Cleanup error: $($_.Exception.Message)"
    }
    
    Write-Host "==========================="
    Write-Error "CONVERSION FAILED: $($_.Exception.Message)"
    exit 1
}
