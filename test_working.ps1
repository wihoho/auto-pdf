param(
    [string]$InputFile = "C:\Users\wihoh\Downloads\ppt\test-presentation-20250824-171947.pptx",
    [string]$OutputFile = "C:\Users\wihoh\Downloads\ppt\test-working.pdf"
)

Write-Host "=== CONVERSION TEST ==="
Write-Host "Input: $InputFile"
Write-Host "Output: $OutputFile"

try {
    Write-Host "Checking input file..."
    if (-not (Test-Path $InputFile)) {
        throw "Input file not found"
    }
    Write-Host "Input file exists"
    
    Write-Host "Creating PowerPoint..."
    $ppt = New-Object -ComObject PowerPoint.Application
    Write-Host "PowerPoint created"
    
    Write-Host "Opening presentation..."
    $presentation = $ppt.Presentations.Open($InputFile, $true, $true, $false)
    Write-Host "Presentation opened"
    
    Write-Host "Exporting to PDF..."
    # Use SaveAs method with PDF format
    $ppSaveAsPDF = 32
    $presentation.SaveAs($OutputFile, $ppSaveAsPDF)
    Write-Host "Export completed"
    
    Write-Host "Cleanup..."
    $presentation.Close()
    $ppt.Quit()
    Write-Host "Cleanup done"
    
    Write-Host "Verifying result..."
    if (Test-Path $OutputFile) {
        $size = (Get-Item $OutputFile).Length
        Write-Host "SUCCESS: PDF created ($size bytes)"
    }
}
catch {
    Write-Host "ERROR: $($_.Exception.Message)"
    exit 1
}
