import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:logging/logging.dart';
import 'conversion_service_interface.dart';

class ConversionServiceMacOS implements ConversionServiceInterface {
  final Logger _logger = Logger('ConversionServiceMacOS');
  
  @override
  String get powerPointAppName => 'Microsoft PowerPoint for Mac';
  
  @override
  String get platformRequirements => 
      'Requires Microsoft PowerPoint for Mac to be installed. '
      'The app will use AppleScript to automate PowerPoint.';
  
  /// Converts a PowerPoint file to PDF using AppleScript automation
  @override
  Future<bool> convertPptToPdf(String pptFilePath) async {
    final startTime = DateTime.now();
    _logger.info('=== MACOS CONVERSION START ===');
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

      // Create AppleScript for conversion
      _logger.info('Step 5: Creating AppleScript...');
      final appleScript = _createAppleScript(pptFilePath, pdfPath);
      _logger.info('AppleScript created (${appleScript.length} characters)');

      // Execute AppleScript
      _logger.info('Step 6: Executing AppleScript...');
      final result = await _executeAppleScript(appleScript);

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
        _logger.severe('AppleScript execution failed');
        return false;
      }

    } catch (e, stackTrace) {
      _logger.severe('Conversion failed with exception: $e');
      _logger.severe('Stack trace: $stackTrace');
      return false;
    }
  }
  
  /// Checks if PowerPoint for Mac is installed by attempting to get its version
  @override
  Future<bool> isPowerPointInstalled() async {
    try {
      _logger.info('Checking PowerPoint for Mac installation...');
      
      final checkScript = '''
tell application "System Events"
    if exists application process "Microsoft PowerPoint" then
        return "PowerPoint is running"
    else
        try
            tell application "Microsoft PowerPoint"
                get version
            end tell
            return "PowerPoint is available"
        on error
            return "PowerPoint not found"
        end try
    end if
end tell
''';

      final result = await Process.run(
        'osascript',
        ['-e', checkScript],
      );

      final isAvailable = result.exitCode == 0 && 
          !result.stdout.toString().contains('PowerPoint not found');
      _logger.info('PowerPoint availability check result: $isAvailable');
      
      if (!isAvailable) {
        _logger.warning('PowerPoint check failed:');
        _logger.warning('  - Exit code: ${result.exitCode}');
        _logger.warning('  - Stdout: ${result.stdout}');
        _logger.warning('  - Stderr: ${result.stderr}');
      } else {
        _logger.info('PowerPoint check output: ${result.stdout}');
      }
      
      return isAvailable;
      
    } catch (e) {
      _logger.severe('Error checking PowerPoint installation: $e');
      return false;
    }
  }
  
  /// Creates an AppleScript for PPT to PDF conversion
  String _createAppleScript(String inputPath, String outputPath) {
    return '''
-- PowerPoint to PDF Conversion Script for macOS
-- Input: $inputPath
-- Output: $outputPath

try
    tell application "Microsoft PowerPoint"
        -- Activate PowerPoint
        activate
        
        -- Open the presentation
        set thePresentation to open POSIX file "$inputPath"
        
        -- Export as PDF
        save thePresentation in POSIX file "$outputPath" as save as PDF
        
        -- Close the presentation
        close thePresentation
        
        return "SUCCESS: Conversion completed"
    end tell
on error errorMessage
    return "ERROR: " & errorMessage
end try
''';
  }
  
  /// Executes an AppleScript and returns success status
  Future<bool> _executeAppleScript(String script) async {
    final executionStart = DateTime.now();
    _logger.info('--- APPLESCRIPT EXECUTION START ---');

    try {
      final result = await Process.run(
        'osascript',
        ['-e', script],
      );

      final executionEnd = DateTime.now();
      final executionDuration = executionEnd.difference(executionStart);

      _logger.info('--- APPLESCRIPT EXECUTION COMPLETE ---');
      _logger.info('Execution time: ${executionDuration.inSeconds} seconds');
      _logger.info('Exit code: ${result.exitCode}');

      // Log stdout
      if (result.stdout.toString().isNotEmpty) {
        _logger.info('=== APPLESCRIPT STDOUT ===');
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
        _logger.warning('=== APPLESCRIPT STDERR ===');
        final stderrLines = result.stderr.toString().split('\n');
        for (final line in stderrLines) {
          if (line.trim().isNotEmpty) {
            _logger.warning('STDERR: $line');
          }
        }
        _logger.warning('=== END STDERR ===');
      }

      // Check for success - both exit code and output content
      final success = result.exitCode == 0 && 
          result.stdout.toString().contains('SUCCESS');
      _logger.info('AppleScript execution result: ${success ? 'SUCCESS' : 'FAILED'}');

      return success;

    } catch (e, stackTrace) {
      final executionEnd = DateTime.now();
      final executionDuration = executionEnd.difference(executionStart);
      
      _logger.severe('AppleScript execution failed after ${executionDuration.inSeconds} seconds');
      _logger.severe('Exception: $e');
      _logger.severe('Stack trace: $stackTrace');
      return false;
    }
  }
}
