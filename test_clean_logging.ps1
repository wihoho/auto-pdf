# Clean test of enhanced PowerShell logging
param(
    [string]$InputFile = "C:\Users\wihoh\Downloads\ppt\test-presentation-20250824-171947.pptx",
    [string]$OutputFile = "C:\Users\wihoh\Downloads\ppt\test-clean-logging.pdf"
)

Write-Host "=== CONVERSION SCRIPT START ==="
Write-Host "Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Host "Input File: $InputFile"
Write-Host "Output File: $OutputFile"
Write-Host ""

$powerpoint = $null
$presentation = $null

try {
    Write-Host "STEP 1: Validating input file..."
    if (-not (Test-Path $InputFile)) {
        throw "Input file does not exist: $InputFile"
    }
    
    $inputFileObj = Get-Item $InputFile
    Write-Host "  ✓ Input file exists"
    Write-Host "  - Size: $($inputFileObj.Length) bytes"
    Write-Host "  - Extension: $($inputFileObj.Extension)"
    
    Write-Host ""
    Write-Host "STEP 2: Creating PowerPoint application..."
    $powerpoint = New-Object -ComObject PowerPoint.Application
    Write-Host "  ✓ PowerPoint application created"
    Write-Host "  - Version: $($powerpoint.Version)"
    
    Write-Host ""
    Write-Host "STEP 3: Opening presentation..."
    $presentation = $powerpoint.Presentations.Open($InputFile, $true, $true, $false)
    Write-Host "  ✓ Presentation opened"
    Write-Host "  - Slide count: $($presentation.Slides.Count)"
    
    Write-Host ""
    Write-Host "STEP 4: Exporting as PDF..."
    $exportStart = Get-Date
    $presentation.ExportAsFixedFormat($OutputFile, 32)
    $exportDuration = (Get-Date) - $exportStart
    Write-Host "  ✓ Export completed in $($exportDuration.TotalSeconds) seconds"
    
    Write-Host ""
    Write-Host "STEP 5: Cleanup..."
    $presentation.Close()
    $powerpoint.Quit()
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($presentation) | Out-Null
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($powerpoint) | Out-Null
    Write-Host "  ✓ Cleanup completed"
    
    Write-Host ""
    Write-Host "STEP 6: Verifying PDF..."
    if (Test-Path $OutputFile) {
        $pdfFile = Get-Item $OutputFile
        Write-Host "  ✓ PDF created successfully"
        Write-Host "  - Size: $($pdfFile.Length) bytes"
        Write-Host ""
        Write-Host "=== CONVERSION SUCCESS ==="
        exit 0
    } else {
        Write-Host "  ✗ PDF file was not created"
        throw "PDF file was not created"
    }
}
catch {
    Write-Host ""
    Write-Host "=== CONVERSION FAILED ==="
    Write-Host "Error: $($_.Exception.Message)"
    Write-Host "Type: $($_.Exception.GetType().Name)"
    Write-Host "Category: $($_.CategoryInfo.Category)"
    
    if ($_.Exception.InnerException) {
        Write-Host "Inner Exception: $($_.Exception.InnerException.Message)"
    }
    
    Write-Host "Stack Trace:"
    Write-Host $_.ScriptStackTrace
    
    # Cleanup on error
    Write-Host ""
    Write-Host "Performing cleanup..."
    if ($presentation) { 
        Write-Host "  - Closing presentation..."
        $presentation.Close() 
    }
    if ($powerpoint) { 
        Write-Host "  - Quitting PowerPoint..."
        $powerpoint.Quit() 
    }
    
    Write-Host "==========================="
    Write-Error "CONVERSION FAILED: $($_.Exception.Message)"
    exit 1
}
