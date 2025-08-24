try {
    Write-Host "Testing PowerPoint COM access..."
    $powerpoint = New-Object -ComObject PowerPoint.Application
    Write-Host "✓ PowerPoint COM object created successfully"
    
    $powerpoint.Visible = $false
    Write-Host "✓ PowerPoint set to invisible mode"
    
    $powerpoint.Quit()
    Write-Host "✓ PowerPoint quit successfully"
    
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($powerpoint) | Out-Null
    Write-Host "✓ COM object released"
    
    Write-Host "SUCCESS: PowerPoint is accessible and working"
    exit 0
}
catch {
    Write-Host "ERROR: PowerPoint test failed"
    Write-Host "Error details: $($_.Exception.Message)"
    Write-Host "Error type: $($_.Exception.GetType().Name)"
    exit 1
}
