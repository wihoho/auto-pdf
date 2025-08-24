param(
    [string]$InputFile = "C:\Users\wihoh\Downloads\ppt\five-forces-aug2025.pptx"
)

Write-Host "Testing PowerPoint to PDF conversion..."
Write-Host "Input file: $InputFile"

# Check if input file exists
if (-not (Test-Path $InputFile)) {
    Write-Host "ERROR: Input file does not exist: $InputFile"
    exit 1
}

# Generate output path
$directory = Split-Path $InputFile -Parent
$filename = [System.IO.Path]::GetFileNameWithoutExtension($InputFile)
$outputFile = Join-Path $directory "$filename.pdf"

Write-Host "Output file: $outputFile"

try {
    Write-Host "Creating PowerPoint application..."
    $powerpoint = New-Object -ComObject PowerPoint.Application
    $powerpoint.Visible = $false
    
    Write-Host "Opening presentation: $InputFile"
    $presentation = $powerpoint.Presentations.Open($InputFile, $true, $true, $false)
    
    Write-Host "Exporting as PDF..."
    # ppSaveAsPDF = 32
    $presentation.ExportAsFixedFormat($outputFile, 32)
    
    Write-Host "Closing presentation..."
    $presentation.Close()
    
    Write-Host "Quitting PowerPoint..."
    $powerpoint.Quit()
    
    # Release COM objects
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($presentation) | Out-Null
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($powerpoint) | Out-Null
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
    
    # Check if PDF was created
    if (Test-Path $outputFile) {
        Write-Host "SUCCESS: PDF created successfully at $outputFile"
        $pdfSize = (Get-Item $outputFile).Length
        Write-Host "PDF file size: $pdfSize bytes"
        exit 0
    } else {
        Write-Host "ERROR: PDF file was not created"
        exit 1
    }
}
catch {
    Write-Host "ERROR: Conversion failed"
    Write-Host "Error details: $($_.Exception.Message)"
    Write-Host "Error type: $($_.Exception.GetType().Name)"
    
    # Cleanup in case of error
    try {
        if ($presentation) { $presentation.Close() }
        if ($powerpoint) { $powerpoint.Quit() }
    } catch {}
    
    exit 1
}
