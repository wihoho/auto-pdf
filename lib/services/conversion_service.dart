import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:logging/logging.dart';

class ConversionService {
  final Logger _logger = Logger('ConversionService');
  
  /// Converts a PowerPoint file to PDF using PowerShell automation
  Future<bool> convertPptToPdf(String pptFilePath) async {
    final startTime = DateTime.now();
    _logger.info('=== CONVERSION START ===');
    _logger.info('Target file: $pptFilePath');
    _logger.info('Start time: $startTime');

    try {
      // Validate input file
      _logger.info('Step 1: Validating input file...');
      final inputFile = File(pptFilePath);

      if (!await inputFile.exists()) {
        _logger.severe('VALIDATION FAILED: Input file does not exist: $pptFilePath');
        return false;
      }

      final fileStats = await inputFile.stat();
      _logger.info('File validation SUCCESS:');
      _logger.info('  - File size: ${fileStats.size} bytes');
      _logger.info('  - Last modified: ${fileStats.modified}');
      _logger.info('  - File type: ${fileStats.type}');

      // Generate output PDF path
      _logger.info('Step 2: Generating output path...');
      final directory = path.dirname(pptFilePath);
      final filename = path.basenameWithoutExtension(pptFilePath);
      final pdfPath = path.join(directory, '$filename.pdf');

      _logger.info('Output path generated:');
      _logger.info('  - Directory: $directory');
      _logger.info('  - Filename (no ext): $filename');
      _logger.info('  - Full PDF path: $pdfPath');

      // Check if PDF already exists
      _logger.info('Step 3: Checking for existing PDF...');
      final pdfFile = File(pdfPath);
      if (await pdfFile.exists()) {
        final existingStats = await pdfFile.stat();
        _logger.warning('PDF already exists:');
        _logger.warning('  - Path: $pdfPath');
        _logger.warning('  - Size: ${existingStats.size} bytes');
        _logger.warning('  - Modified: ${existingStats.modified}');
        _logger.warning('Skipping conversion');
        return true;
      }
      _logger.info('No existing PDF found, proceeding with conversion');

      // Check directory permissions
      _logger.info('Step 4: Checking directory permissions...');
      try {
        final testFile = File(path.join(directory, 'test_write_${DateTime.now().millisecondsSinceEpoch}.tmp'));
        await testFile.writeAsString('test');
        await testFile.delete();
        _logger.info('Directory write permissions: OK');
      } catch (e) {
        _logger.severe('Directory write permission check FAILED: $e');
        return false;
      }

      // Create PowerShell script for conversion
      _logger.info('Step 5: Creating PowerShell script...');
      final powershellScript = _createPowerShellScript(pptFilePath, pdfPath);
      _logger.info('PowerShell script created (${powershellScript.length} characters)');

      // Execute PowerShell script
      _logger.info('Step 6: Executing PowerShell script...');
      final result = await _executePowerShellScript(powershellScript);

      _logger.info('Step 7: Verifying conversion result...');
      if (result) {
        // Verify PDF was created
        if (await pdfFile.exists()) {
          final finalStats = await pdfFile.stat();
          final duration = DateTime.now().difference(startTime);

          _logger.info('=== CONVERSION SUCCESS ===');
          _logger.info('Input: $pptFilePath');
          _logger.info('Output: $pdfPath');
          _logger.info('PDF size: ${finalStats.size} bytes');
          _logger.info('Duration: ${duration.inMilliseconds}ms');
          _logger.info('========================');
          return true;
        } else {
          _logger.severe('=== CONVERSION FAILED ===');
          _logger.severe('PowerShell reported success but PDF file not found');
          _logger.severe('Expected path: $pdfPath');
          _logger.severe('Directory contents:');

          try {
            final dir = Directory(directory);
            final contents = await dir.list().toList();
            for (final item in contents) {
              _logger.severe('  - ${item.path}');
            }
          } catch (e) {
            _logger.severe('Could not list directory contents: $e');
          }

          return false;
        }
      } else {
        final duration = DateTime.now().difference(startTime);
        _logger.severe('=== CONVERSION FAILED ===');
        _logger.severe('PowerShell script execution failed');
        _logger.severe('File: $pptFilePath');
        _logger.severe('Duration: ${duration.inMilliseconds}ms');
        _logger.severe('========================');
        return false;
      }

    } catch (e, stackTrace) {
      final duration = DateTime.now().difference(startTime);
      _logger.severe('=== CONVERSION ERROR ===');
      _logger.severe('Unexpected error during conversion');
      _logger.severe('File: $pptFilePath');
      _logger.severe('Duration: ${duration.inMilliseconds}ms');
      _logger.severe('Error: $e');
      _logger.severe('Stack trace: $stackTrace');
      _logger.severe('=======================');
      return false;
    }
  }
  
  /// Creates a PowerShell script for PPT to PDF conversion
  String _createPowerShellScript(String inputPath, String outputPath) {
    // Escape paths for PowerShell - use double quotes and escape internal quotes
    final escapedInputPath = inputPath.replaceAll('"', '""');
    final escapedOutputPath = outputPath.replaceAll('"', '""');

    return '''
# ===== PowerPoint to PDF Conversion Script =====
Write-Host "=== CONVERSION SCRIPT START ==="
Write-Host "Timestamp: \$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Host "PowerShell Version: \$(\$PSVersionTable.PSVersion)"
Write-Host "Input File: $escapedInputPath"
Write-Host "Output File: $escapedOutputPath"
Write-Host ""

try {
    # Step 1: Validate input file
    Write-Host "STEP 1: Validating input file..."
    if (-not (Test-Path "$escapedInputPath")) {
        throw "Input file does not exist: $escapedInputPath"
    }

    \$inputFile = Get-Item "$escapedInputPath"
    Write-Host "  [OK] Input file exists"
    Write-Host "  - Full path: \$(\$inputFile.FullName)"
    Write-Host "  - Size: \$(\$inputFile.Length) bytes"
    Write-Host "  - Last modified: \$(\$inputFile.LastWriteTime)"
    Write-Host "  - Extension: \$(\$inputFile.Extension)"

    # Step 2: Check output directory
    Write-Host ""
    Write-Host "STEP 2: Checking output directory..."
    \$outputDir = Split-Path "$escapedOutputPath" -Parent
    if (-not (Test-Path \$outputDir)) {
        throw "Output directory does not exist: \$outputDir"
    }
    Write-Host "  [OK] Output directory exists: \$outputDir"

    # Step 3: Test PowerPoint COM availability
    Write-Host ""
    Write-Host "STEP 3: Testing PowerPoint COM availability..."
    try {
        \$testPpt = New-Object -ComObject PowerPoint.Application
        \$testPpt.Quit()
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject(\$testPpt) | Out-Null
        Write-Host "  [OK] PowerPoint COM object accessible"
    } catch {
        throw "PowerPoint COM object not available: \$(\$_.Exception.Message)"
    }

    # Step 4: Create PowerPoint application
    Write-Host ""
    Write-Host "STEP 4: Creating PowerPoint application..."
    \$powerpoint = New-Object -ComObject PowerPoint.Application
    Write-Host "  [OK] PowerPoint application created"
    Write-Host "  - Version: \$(\$powerpoint.Version)"
    Write-Host "  - Build: \$(\$powerpoint.Build)"

    # Step 5: Open presentation
    Write-Host ""
    Write-Host "STEP 5: Opening presentation..."
    Write-Host "  - Opening file: $escapedInputPath"
    \$presentation = \$powerpoint.Presentations.Open("$escapedInputPath", -1, -1, 0)  # msoTrue = -1, msoFalse = 0
    Write-Host "  [OK] Presentation opened successfully"
    Write-Host "  - Slide count: \$(\$presentation.Slides.Count)"
    Write-Host "  - Name: \$(\$presentation.Name)"

    # Step 6: Export as PDF
    Write-Host ""
    Write-Host "STEP 6: Exporting as PDF..."
    Write-Host "  - Target path: $escapedOutputPath"
    Write-Host "  - Format: PDF (ppSaveAsPDF = 32)"

    \$exportStart = Get-Date
    \$ppSaveAsPDF = 32
    \$presentation.SaveAs("$escapedOutputPath", \$ppSaveAsPDF)
    \$exportDuration = (Get-Date) - \$exportStart

    Write-Host "  [OK] Export completed in \$(\$exportDuration.TotalSeconds) seconds"

    # Step 7: Close presentation
    Write-Host ""
    Write-Host "STEP 7: Closing presentation..."
    \$presentation.Close()
    Write-Host "  [OK] Presentation closed"

    # Step 8: Quit PowerPoint
    Write-Host ""
    Write-Host "STEP 8: Quitting PowerPoint..."
    \$powerpoint.Quit()
    Write-Host "  [OK] PowerPoint quit successfully"

    # Step 9: Release COM objects
    Write-Host ""
    Write-Host "STEP 9: Releasing COM objects..."
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject(\$presentation) | Out-Null
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject(\$powerpoint) | Out-Null
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
    Write-Host "  [OK] COM objects released and garbage collected"

    # Step 10: Verify PDF creation
    Write-Host ""
    Write-Host "STEP 10: Verifying PDF creation..."
    if (Test-Path "$escapedOutputPath") {
        \$pdfFile = Get-Item "$escapedOutputPath"
        Write-Host "  [OK] PDF file created successfully"
        Write-Host "  - Path: \$(\$pdfFile.FullName)"
        Write-Host "  - Size: \$(\$pdfFile.Length) bytes"
        Write-Host "  - Created: \$(\$pdfFile.CreationTime)"

        Write-Host ""
        Write-Host "=== CONVERSION SUCCESS ==="
        Write-Host "Completed at: \$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
        exit 0
    } else {
        throw "PDF file was not created at expected location: $escapedOutputPath"
    }
}
catch {
    Write-Host ""
    Write-Host "=== CONVERSION FAILED ==="
    Write-Host "Error occurred at: \$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    Write-Host "Error Message: \$(\$_.Exception.Message)"
    Write-Host "Error Type: \$(\$_.Exception.GetType().Name)"
    Write-Host "Error Category: \$(\$_.CategoryInfo.Category)"

    if (\$_.Exception.InnerException) {
        Write-Host "Inner Exception: \$(\$_.Exception.InnerException.Message)"
    }

    Write-Host "Stack Trace:"
    Write-Host \$_.ScriptStackTrace

    # Cleanup in case of error
    Write-Host ""
    Write-Host "Performing cleanup..."
    try {
        if (\$presentation) {
            Write-Host "  - Closing presentation..."
            \$presentation.Close()
            Write-Host "  [OK] Presentation closed"
        }
        if (\$powerpoint) {
            Write-Host "  - Quitting PowerPoint..."
            \$powerpoint.Quit()
            Write-Host "  [OK] PowerPoint quit"
        }
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject(\$presentation) | Out-Null
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject(\$powerpoint) | Out-Null
        Write-Host "  [OK] COM objects released"
    } catch {
        Write-Host "  ! Cleanup error: \$(\$_.Exception.Message)"
    }

    Write-Host "==========================="
    Write-Error "CONVERSION FAILED: \$(\$_.Exception.Message)"
    exit 1
}
''';
  }
  
  /// Creates a PowerShell script for Word to PDF conversion
  String _createWordPowerShellScript(String inputPath, String outputPath) {
    // Escape paths for PowerShell - use double quotes and escape internal quotes
    final escapedInputPath = inputPath.replaceAll('"', '""');
    final escapedOutputPath = outputPath.replaceAll('"', '""');

    return '''
# ===== Word to PDF Conversion Script =====
Write-Host "=== CONVERSION SCRIPT START ==="
Write-Host "Timestamp: \$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Host "PowerShell Version: \$(\$PSVersionTable.PSVersion)"
Write-Host "Input File: $escapedInputPath"
Write-Host "Output File: $escapedOutputPath"
Write-Host ""

try {
    # Step 1: Validate input file
    Write-Host "STEP 1: Validating input file..."
    if (-not (Test-Path "$escapedInputPath")) {
        throw "Input file does not exist: $escapedInputPath"
    }

    \$inputFile = Get-Item "$escapedInputPath"
    Write-Host "  [OK] Input file exists"
    Write-Host "  - Full path: \$(\$inputFile.FullName)"
    Write-Host "  - Size: \$(\$inputFile.Length) bytes"
    Write-Host "  - Last modified: \$(\$inputFile.LastWriteTime)"
    Write-Host "  - Extension: \$(\$inputFile.Extension)"

    # Step 2: Check output directory
    Write-Host ""
    Write-Host "STEP 2: Checking output directory..."
    \$outputDir = Split-Path "$escapedOutputPath" -Parent
    if (-not (Test-Path \$outputDir)) {
        throw "Output directory does not exist: \$outputDir"
    }
    Write-Host "  [OK] Output directory exists: \$outputDir"

    # Step 3: Test Word COM availability
    Write-Host ""
    Write-Host "STEP 3: Testing Word COM availability..."
    try {
        \$testWord = New-Object -ComObject Word.Application
        \$testWord.Quit()
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject(\$testWord) | Out-Null
        Write-Host "  [OK] Word COM object accessible"
    } catch {
        throw "Word COM object not available: \$(\$_.Exception.Message)"
    }

    # Step 4: Create Word application
    Write-Host ""
    Write-Host "STEP 4: Creating Word application..."
    \$word = New-Object -ComObject Word.Application
    Write-Host "  [OK] Word application created"
    Write-Host "  - Version: \$(\$word.Version)"
    Write-Host "  - Build: \$(\$word.Build)"

    # Step 5: Open document
    Write-Host ""
    Write-Host "STEP 5: Opening document..."
    Write-Host "  - Opening file: $escapedInputPath"
    \$document = \$word.Documents.Open("$escapedInputPath", \$false, \$true)  # ReadOnly = true, AddToRecentFiles = false
    Write-Host "  [OK] Document opened successfully"
    Write-Host "  - Page count: \$(\$document.ComputeStatistics(2))"  # wdStatisticPages = 2
    Write-Host "  - Word count: \$(\$document.ComputeStatistics(0))"  # wdStatisticWords = 0
    Write-Host "  - Name: \$(\$document.Name)"

    # Step 6: Export as PDF
    Write-Host ""
    Write-Host "STEP 6: Exporting as PDF..."
    Write-Host "  - Target path: $escapedOutputPath"
    Write-Host "  - Using ExportAsFixedFormat method"

    \$exportStart = Get-Date
    \$wdExportFormatPDF = 17
    \$wdExportOptimizeForPrint = 0
    \$wdExportCreateBookmarks = 1
    \$document.ExportAsFixedFormat("$escapedOutputPath", \$wdExportFormatPDF, \$false, \$wdExportOptimizeForPrint, \$wdExportCreateBookmarks)
    \$exportDuration = (Get-Date) - \$exportStart

    Write-Host "  [OK] Export completed in \$(\$exportDuration.TotalSeconds) seconds"

    # Step 7: Close document
    Write-Host ""
    Write-Host "STEP 7: Closing document..."
    \$document.Close()
    Write-Host "  [OK] Document closed"

    # Step 8: Quit Word
    Write-Host ""
    Write-Host "STEP 8: Quitting Word..."
    \$word.Quit()
    Write-Host "  [OK] Word quit successfully"

    # Step 9: Release COM objects
    Write-Host ""
    Write-Host "STEP 9: Releasing COM objects..."
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject(\$document) | Out-Null
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject(\$word) | Out-Null
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
    Write-Host "  [OK] COM objects released and garbage collected"

    # Step 10: Verify PDF creation
    Write-Host ""
    Write-Host "STEP 10: Verifying PDF creation..."
    if (Test-Path "$escapedOutputPath") {
        \$pdfFile = Get-Item "$escapedOutputPath"
        Write-Host "  [OK] PDF file created successfully"
        Write-Host "  - Path: \$(\$pdfFile.FullName)"
        Write-Host "  - Size: \$(\$pdfFile.Length) bytes"
        Write-Host "  - Created: \$(\$pdfFile.CreationTime)"

        Write-Host ""
        Write-Host "=== CONVERSION SUCCESS ==="
        Write-Host "Completed at: \$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
        exit 0
    } else {
        throw "PDF file was not created at expected location: $escapedOutputPath"
    }
}
catch {
    Write-Host ""
    Write-Host "=== CONVERSION FAILED ==="
    Write-Host "Error occurred at: \$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    Write-Host "Error Message: \$(\$_.Exception.Message)"
    Write-Host "Error Type: \$(\$_.Exception.GetType().Name)"
    Write-Host "Error Category: \$(\$_.CategoryInfo.Category)"

    if (\$_.Exception.InnerException) {
        Write-Host "Inner Exception: \$(\$_.Exception.InnerException.Message)"
    }

    Write-Host "Stack Trace:"
    Write-Host \$_.ScriptStackTrace

    # Cleanup in case of error
    Write-Host ""
    Write-Host "Performing cleanup..."
    try {
        if (\$document) {
            Write-Host "  - Closing document..."
            \$document.Close()
            Write-Host "  [OK] Document closed"
        }
        if (\$word) {
            Write-Host "  - Quitting Word..."
            \$word.Quit()
            Write-Host "  [OK] Word quit"
        }
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject(\$document) | Out-Null
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject(\$word) | Out-Null
        Write-Host "  [OK] COM objects released"
    } catch {
        Write-Host "  ! Cleanup error: \$(\$_.Exception.Message)"
    }

    Write-Host "==========================="
    Write-Error "CONVERSION FAILED: \$(\$_.Exception.Message)"
    exit 1
}
''';
  }
  Future<bool> _executePowerShellScript(String script) async {
    final executionStart = DateTime.now();
    _logger.info('--- POWERSHELL EXECUTION START ---');

    try {
      // Create temporary script file
      final tempDir = Directory.systemTemp;
      final scriptFile = File(path.join(tempDir.path, 'ppt_conversion_${DateTime.now().millisecondsSinceEpoch}.ps1'));

      _logger.info('PowerShell setup:');
      _logger.info('  - Temp directory: ${tempDir.path}');
      _logger.info('  - Script file: ${scriptFile.path}');
      _logger.info('  - Script length: ${script.length} characters');

      // Write script with detailed logging
      _logger.info('Writing PowerShell script to temp file...');
      await scriptFile.writeAsString(script);

      // Verify script was written
      if (await scriptFile.exists()) {
        final scriptStats = await scriptFile.stat();
        _logger.info('Script file written successfully:');
        _logger.info('  - File size: ${scriptStats.size} bytes');
      } else {
        _logger.severe('FAILED to write script file');
        return false;
      }

      try {
        _logger.info('Launching PowerShell process...');
        final processArgs = [
          '-ExecutionPolicy', 'Bypass',
          '-NoProfile',
          '-File', scriptFile.path
        ];

        _logger.info('PowerShell command:');
        _logger.info('  - Executable: powershell.exe');
        _logger.info('  - Arguments: ${processArgs.join(' ')}');

        final processStart = DateTime.now();

        // Execute PowerShell script with detailed logging
        final result = await Process.run(
          'powershell.exe',
          processArgs,
          runInShell: true,
        );

        final processDuration = DateTime.now().difference(processStart);

        _logger.info('PowerShell process completed:');
        _logger.info('  - Duration: ${processDuration.inMilliseconds}ms');
        _logger.info('  - Exit code: ${result.exitCode}');

        // Log stdout with line numbers for easier debugging
        if (result.stdout.isNotEmpty) {
          _logger.info('PowerShell STDOUT:');
          final stdoutLines = result.stdout.toString().split('\n');
          for (int i = 0; i < stdoutLines.length; i++) {
            if (stdoutLines[i].trim().isNotEmpty) {
              _logger.info('  ${(i + 1).toString().padLeft(3)}: ${stdoutLines[i]}');
            }
          }
        } else {
          _logger.warning('PowerShell STDOUT: (empty)');
        }

        // Log stderr with line numbers for easier debugging
        if (result.stderr.isNotEmpty) {
          _logger.severe('PowerShell STDERR:');
          final stderrLines = result.stderr.toString().split('\n');
          for (int i = 0; i < stderrLines.length; i++) {
            if (stderrLines[i].trim().isNotEmpty) {
              _logger.severe('  ${(i + 1).toString().padLeft(3)}: ${stderrLines[i]}');
            }
          }
        } else {
          _logger.info('PowerShell STDERR: (empty)');
        }

        final success = result.exitCode == 0;
        final totalDuration = DateTime.now().difference(executionStart);

        if (success) {
          _logger.info('--- POWERSHELL EXECUTION SUCCESS ---');
          _logger.info('Total duration: ${totalDuration.inMilliseconds}ms');
        } else {
          _logger.severe('--- POWERSHELL EXECUTION FAILED ---');
          _logger.severe('Exit code: ${result.exitCode}');
          _logger.severe('Total duration: ${totalDuration.inMilliseconds}ms');
        }

        return success;

      } finally {
        // Clean up temporary script file
        _logger.info('Cleaning up temporary script file...');
        try {
          if (await scriptFile.exists()) {
            await scriptFile.delete();
            _logger.info('Temporary script file deleted successfully');
          } else {
            _logger.warning('Temporary script file already gone');
          }
        } catch (e) {
          _logger.warning('Failed to delete temporary script file: $e');
        }
      }

    } catch (e, stackTrace) {
      final totalDuration = DateTime.now().difference(executionStart);
      _logger.severe('--- POWERSHELL EXECUTION ERROR ---');
      _logger.severe('Duration: ${totalDuration.inMilliseconds}ms');
      _logger.severe('Error: $e');
      _logger.severe('Stack trace: $stackTrace');
      return false;
    }
  }
  
  /// Checks if Microsoft PowerPoint is installed on the system
  Future<bool> isPowerPointInstalled() async {
    try {
      final result = await Process.run(
        'powershell.exe',
        [
          '-Command',
          'Get-ItemProperty "HKLM:\\Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\*" | Where-Object {\$_.DisplayName -like "*Microsoft*PowerPoint*"} | Select-Object DisplayName'
        ],
        runInShell: true,
      );
      
      return result.exitCode == 0 && result.stdout.toString().contains('PowerPoint');
    } catch (e) {
      _logger.warning('Error checking PowerPoint installation: $e');
      return false;
    }
  }
  
  /// Checks if Microsoft Word is installed on the system
  Future<bool> isWordInstalled() async {
    try {
      final result = await Process.run(
        'powershell.exe',
        [
          '-Command',
          'Get-ItemProperty "HKLM:\\Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\*" | Where-Object {\$_.DisplayName -like "*Microsoft*Word*"} | Select-Object DisplayName'
        ],
        runInShell: true,
      );
      
      return result.exitCode == 0 && result.stdout.toString().contains('Word');
    } catch (e) {
      _logger.warning('Error checking Word installation: $e');
      return false;
    }
  }
  
  /// Converts a Word document to PDF using PowerShell automation
  Future<bool> convertDocToPdf(String docFilePath) async {
    final startTime = DateTime.now();
    _logger.info('=== DOC CONVERSION START ===');
    _logger.info('Target file: $docFilePath');
    _logger.info('Start time: $startTime');

    try {
      // Validate input file
      _logger.info('Step 1: Validating input file...');
      final inputFile = File(docFilePath);

      if (!await inputFile.exists()) {
        _logger.severe('VALIDATION FAILED: Input file does not exist: $docFilePath');
        return false;
      }

      final fileStats = await inputFile.stat();
      _logger.info('File validation SUCCESS:');
      _logger.info('  - File size: ${fileStats.size} bytes');
      _logger.info('  - Last modified: ${fileStats.modified}');
      _logger.info('  - File type: ${fileStats.type}');

      // Generate output PDF path
      _logger.info('Step 2: Generating output path...');
      final directory = path.dirname(docFilePath);
      final filename = path.basenameWithoutExtension(docFilePath);
      final pdfPath = path.join(directory, '$filename.pdf');

      _logger.info('Output path generated:');
      _logger.info('  - Directory: $directory');
      _logger.info('  - Filename (no ext): $filename');
      _logger.info('  - Full PDF path: $pdfPath');

      // Check if PDF already exists
      _logger.info('Step 3: Checking for existing PDF...');
      final pdfFile = File(pdfPath);
      if (await pdfFile.exists()) {
        final existingStats = await pdfFile.stat();
        _logger.warning('PDF already exists:');
        _logger.warning('  - Path: $pdfPath');
        _logger.warning('  - Size: ${existingStats.size} bytes');
        _logger.warning('  - Modified: ${existingStats.modified}');
        _logger.warning('Skipping conversion');
        return true;
      }
      _logger.info('No existing PDF found, proceeding with conversion');

      // Check directory permissions
      _logger.info('Step 4: Checking directory permissions...');
      try {
        final testFile = File(path.join(directory, 'test_write_${DateTime.now().millisecondsSinceEpoch}.tmp'));
        await testFile.writeAsString('test');
        await testFile.delete();
        _logger.info('Directory write permissions: OK');
      } catch (e) {
        _logger.severe('Directory write permission check FAILED: $e');
        return false;
      }

      // Create PowerShell script for conversion
      _logger.info('Step 5: Creating PowerShell script...');
      final powershellScript = _createWordPowerShellScript(docFilePath, pdfPath);
      _logger.info('PowerShell script created (${powershellScript.length} characters)');

      // Execute PowerShell script
      _logger.info('Step 6: Executing PowerShell script...');
      final result = await _executePowerShellScript(powershellScript);

      _logger.info('Step 7: Verifying conversion result...');
      if (result) {
        // Verify PDF was created
        if (await pdfFile.exists()) {
          final finalStats = await pdfFile.stat();
          final duration = DateTime.now().difference(startTime);

          _logger.info('=== DOC CONVERSION SUCCESS ===');
          _logger.info('Input: $docFilePath');
          _logger.info('Output: $pdfPath');
          _logger.info('PDF size: ${finalStats.size} bytes');
          _logger.info('Duration: ${duration.inMilliseconds}ms');
          _logger.info('========================');
          return true;
        } else {
          _logger.severe('=== DOC CONVERSION FAILED ===');
          _logger.severe('PowerShell reported success but PDF file not found');
          _logger.severe('Expected path: $pdfPath');
          _logger.severe('Directory contents:');

          try {
            final dir = Directory(directory);
            final contents = await dir.list().toList();
            for (final item in contents) {
              _logger.severe('  - ${item.path}');
            }
          } catch (e) {
            _logger.severe('Could not list directory contents: $e');
          }

          return false;
        }
      } else {
        final duration = DateTime.now().difference(startTime);
        _logger.severe('=== DOC CONVERSION FAILED ===');
        _logger.severe('PowerShell script execution failed');
        _logger.severe('File: $docFilePath');
        _logger.severe('Duration: ${duration.inMilliseconds}ms');
        _logger.severe('========================');
        return false;
      }

    } catch (e, stackTrace) {
      final duration = DateTime.now().difference(startTime);
      _logger.severe('=== DOC CONVERSION ERROR ===');
      _logger.severe('Unexpected error during conversion');
      _logger.severe('File: $docFilePath');
      _logger.severe('Duration: ${duration.inMilliseconds}ms');
      _logger.severe('Error: $e');
      _logger.severe('Stack trace: $stackTrace');
      _logger.severe('=======================');
      return false;
    }
  }
}
