import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:logging/logging.dart';
import 'conversion_service_interface.dart';

class ConversionServiceWindows implements ConversionServiceInterface {
  final Logger _logger = Logger('ConversionServiceWindows');
  
  @override
  String get powerPointAppName => 'Microsoft PowerPoint';
  
  @override
  String get platformRequirements => 
      'Requires Microsoft PowerPoint to be installed on Windows';
  
  /// Converts a PowerPoint file to PDF using PowerShell automation
  @override
  Future<bool> convertPptToPdf(String pptFilePath) async {
    final startTime = DateTime.now();
    _logger.info('=== WINDOWS CONVERSION START ===');
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
        _logger.info('PDF already exists, checking timestamps...');
        final pdfStats = await pdfFile.stat();
        
        if (pdfStats.modified.isAfter(fileStats.modified)) {
          _logger.info('PDF is newer than source file, skipping conversion');
          _logger.info('  - PPT modified: ${fileStats.modified}');
          _logger.info('  - PDF modified: ${pdfStats.modified}');
          return true;
        } else {
          _logger.info('PDF is older than source file, will reconvert');
          _logger.info('  - PPT modified: ${fileStats.modified}');
          _logger.info('  - PDF modified: ${pdfStats.modified}');
        }
      } else {
        _logger.info('No existing PDF found, will create new one');
      }

      // Check PowerPoint availability
      _logger.info('Step 4: Checking PowerPoint availability...');
      final isPowerPointAvailable = await isPowerPointInstalled();
      if (!isPowerPointAvailable) {
        _logger.severe('PowerPoint is not available for conversion');
        return false;
      }
      _logger.info('PowerPoint availability confirmed');

      // Create PowerShell script for conversion
      _logger.info('Step 5: Creating PowerShell script...');
      final powershellScript = _createPowerShellScript(pptFilePath, pdfPath);
      _logger.info('PowerShell script created (${powershellScript.length} characters)');

      // Execute PowerShell script
      _logger.info('Step 6: Executing PowerShell script...');
      final result = await _executePowerShellScript(powershellScript);

      if (result) {
        final endTime = DateTime.now();
        final duration = endTime.difference(startTime);
        _logger.info('=== CONVERSION SUCCESS ===');
        _logger.info('Total duration: ${duration.inSeconds} seconds');
        _logger.info('Output file: $pdfPath');
        
        // Verify the output file was created
        if (await pdfFile.exists()) {
          final finalStats = await pdfFile.stat();
          _logger.info('Final PDF size: ${finalStats.size} bytes');
          return true;
        } else {
          _logger.severe('Conversion reported success but PDF file was not created');
          return false;
        }
      } else {
        _logger.severe('PowerShell script execution failed');
        return false;
      }

    } catch (e, stackTrace) {
      _logger.severe('Conversion failed with exception: $e');
      _logger.severe('Stack trace: $stackTrace');
      return false;
    }
  }
  
  /// Checks if PowerPoint is installed by attempting to create a COM object
  @override
  Future<bool> isPowerPointInstalled() async {
    try {
      _logger.info('Checking PowerPoint installation...');
      
      final checkScript = '''
try {
    \$powerpoint = New-Object -ComObject PowerPoint.Application
    \$powerpoint.Quit()
    Write-Host "PowerPoint is available"
    exit 0
} catch {
    Write-Host "PowerPoint is not available: \$(\$_.Exception.Message)"
    exit 1
}
''';

      final result = await Process.run(
        'powershell.exe',
        ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-Command', checkScript],
        runInShell: true,
      );

      final isAvailable = result.exitCode == 0;
      _logger.info('PowerPoint availability check result: $isAvailable');
      
      if (!isAvailable) {
        _logger.warning('PowerPoint check failed:');
        _logger.warning('  - Exit code: ${result.exitCode}');
        _logger.warning('  - Stdout: ${result.stdout}');
        _logger.warning('  - Stderr: ${result.stderr}');
      }
      
      return isAvailable;
      
    } catch (e) {
      _logger.severe('Error checking PowerPoint installation: $e');
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
        Write-Error "Input file does not exist: $escapedInputPath"
        exit 1
    }

    \$inputFile = Get-Item "$escapedInputPath"
    Write-Host "  [OK] Input file exists"
    Write-Host "  - Size: \$(\$inputFile.Length) bytes"
    Write-Host "  - Last Modified: \$(\$inputFile.LastWriteTime)"

    # Step 2: Create PowerPoint application
    Write-Host ""
    Write-Host "STEP 2: Creating PowerPoint application..."
    \$creationStart = Get-Date
    \$powerpoint = New-Object -ComObject PowerPoint.Application
    \$creationDuration = (Get-Date) - \$creationStart

    Write-Host "  [OK] PowerPoint application created in \$(\$creationDuration.TotalSeconds) seconds"
    Write-Host "  - Version: \$(\$powerpoint.Version)"

    # Ensure PowerPoint is not visible
    \$powerpoint.Visible = \$false

    # Step 3: Open presentation
    Write-Host ""
    Write-Host "STEP 3: Opening presentation..."
    \$openStart = Get-Date
    \$presentation = \$powerpoint.Presentations.Open("$escapedInputPath", \$true, \$true, \$false)
    \$openDuration = (Get-Date) - \$openStart

    Write-Host "  [OK] Presentation opened in \$(\$openDuration.TotalSeconds) seconds"
    Write-Host "  - Slides count: \$(\$presentation.Slides.Count)"

    # Step 4: Export as PDF
    Write-Host ""
    Write-Host "STEP 4: Exporting as PDF..."
    \$exportStart = Get-Date
    \$ppSaveAsPDF = 32
    \$presentation.SaveAs("$escapedOutputPath", \$ppSaveAsPDF)
    \$exportDuration = (Get-Date) - \$exportStart

    Write-Host "  [OK] Export completed in \$(\$exportDuration.TotalSeconds) seconds"

    # Step 5: Cleanup
    Write-Host ""
    Write-Host "STEP 5: Cleanup..."
    \$presentation.Close()
    \$powerpoint.Quit()
    Write-Host "  [OK] Cleanup completed"

    # Step 6: Verify output
    Write-Host ""
    Write-Host "STEP 6: Verifying output file..."
    if (Test-Path "$escapedOutputPath") {
        \$outputFile = Get-Item "$escapedOutputPath"
        Write-Host "  [OK] PDF file created successfully"
        Write-Host "  - Size: \$(\$outputFile.Length) bytes"

        if (\$outputFile.Length -eq 0) {
            Write-Error "PDF file was created but is empty (0 bytes)"
            exit 1
        }
    } else {
        Write-Error "PDF file was not created"
        exit 1
    }

    Write-Host ""
    Write-Host "=== CONVERSION COMPLETED SUCCESSFULLY ==="
    exit 0

} catch {
    # Cleanup on error
    Write-Host ""
    Write-Host "ERROR OCCURRED - Attempting cleanup..."

    try {
        if (\$presentation) { \$presentation.Close() }
        if (\$powerpoint) { \$powerpoint.Quit() }
    } catch {
        Write-Host "  [WARN] Could not complete cleanup"
    }

    Write-Host "==========================="
    Write-Error "CONVERSION FAILED: \$(\$_.Exception.Message)"
    exit 1
}
''';
  }

  /// Executes a PowerShell script and returns success status
  Future<bool> _executePowerShellScript(String script) async {
    final executionStart = DateTime.now();
    _logger.info('--- POWERSHELL EXECUTION START ---');

    try {
      final result = await Process.run(
        'powershell.exe',
        [
          '-NoProfile',
          '-ExecutionPolicy', 'Bypass',
          '-Command', script
        ],
        runInShell: true,
      );

      final executionEnd = DateTime.now();
      final executionDuration = executionEnd.difference(executionStart);

      _logger.info('--- POWERSHELL EXECUTION COMPLETE ---');
      _logger.info('Execution time: ${executionDuration.inSeconds} seconds');
      _logger.info('Exit code: ${result.exitCode}');

      // Log stdout
      if (result.stdout.toString().isNotEmpty) {
        _logger.info('=== POWERSHELL STDOUT ===');
        final stdoutLines = result.stdout.toString().split('\n');
        for (final line in stdoutLines) {
          if (line.trim().isNotEmpty) {
            _logger.info('STDOUT: $line');
          }
        }
        _logger.info('=== END STDOUT ===');
      }

      // Log stderr
      if (result.stderr.toString().isNotEmpty) {
        _logger.warning('=== POWERSHELL STDERR ===');
        final stderrLines = result.stderr.toString().split('\n');
        for (final line in stderrLines) {
          if (line.trim().isNotEmpty) {
            _logger.warning('STDERR: $line');
          }
        }
        _logger.warning('=== END STDERR ===');
      }

      final success = result.exitCode == 0;
      _logger.info('PowerShell execution result: ${success ? 'SUCCESS' : 'FAILED'}');

      return success;

    } catch (e, stackTrace) {
      final executionEnd = DateTime.now();
      final executionDuration = executionEnd.difference(executionStart);

      _logger.severe('PowerShell execution failed after ${executionDuration.inSeconds} seconds');
      _logger.severe('Exception: $e');
      _logger.severe('Stack trace: $stackTrace');
      return false;
    }
  }
}
