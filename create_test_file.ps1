param(
    [string]$OutputDir = "C:\Users\wihoh\Downloads\ppt"
)

Write-Host "Creating test PowerPoint file..."

# Ensure output directory exists
if (-not (Test-Path $OutputDir)) {
    Write-Host "Creating directory: $OutputDir"
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

try {
    Write-Host "Starting PowerPoint..."
    $powerpoint = New-Object -ComObject PowerPoint.Application
    # Don't set Visible property, it's not needed for file creation
    
    Write-Host "Creating new presentation..."
    $presentation = $powerpoint.Presentations.Add()
    
    # Add title slide
    $slide1 = $presentation.Slides.Add(1, 1) # ppLayoutTitle = 1
    $slide1.Shapes.Title.TextFrame.TextRange.Text = "Test Presentation"
    $slide1.Shapes.Placeholders[2].TextFrame.TextRange.Text = "This is a test PowerPoint file for Auto PDF Converter testing"
    
    # Add content slide
    $slide2 = $presentation.Slides.Add(2, 2) # ppLayoutText = 2
    $slide2.Shapes.Title.TextFrame.TextRange.Text = "Test Content"
    $slide2.Shapes.Placeholders[2].TextFrame.TextRange.Text = "• This is bullet point 1`n• This is bullet point 2`n• This is bullet point 3`n`nThis file should be automatically converted to PDF when copied to the monitored folder."
    
    # Save the presentation
    $testFile = Join-Path $OutputDir "test-presentation-$(Get-Date -Format 'yyyyMMdd-HHmmss').pptx"
    Write-Host "Saving presentation to: $testFile"
    $presentation.SaveAs($testFile)
    
    # Close and cleanup
    $presentation.Close()
    $powerpoint.Quit()
    
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($presentation) | Out-Null
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($powerpoint) | Out-Null
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
    
    Write-Host "SUCCESS: Test file created at $testFile"
    Write-Host ""
    Write-Host "Instructions:"
    Write-Host "1. In the Auto PDF Converter app, select the folder: $OutputDir"
    Write-Host "2. Click 'Start Monitoring'"
    Write-Host "3. Copy the test file with a new name to trigger conversion"
    Write-Host "   Example: Copy-Item '$testFile' '$OutputDir\new-test.pptx'"
    
    return $testFile
}
catch {
    Write-Host "ERROR: Failed to create test file"
    Write-Host "Error: $($_.Exception.Message)"
    
    # Cleanup
    try {
        if ($presentation) { $presentation.Close() }
        if ($powerpoint) { $powerpoint.Quit() }
    } catch {}
    
    return $null
}
