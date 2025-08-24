import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:logging/logging.dart';

class ConversionService {
  final Logger _logger = Logger('ConversionService');
  
  /// Converts a PowerPoint file to PDF using PowerShell automation
  Future<bool> convertPptToPdf(String pptFilePath) async {
    try {
      _logger.info('Starting conversion of: $pptFilePath');
      
      // Validate input file
      final inputFile = File(pptFilePath);
      if (!await inputFile.exists()) {
        _logger.severe('Input file does not exist: $pptFilePath');
        return false;
      }
      
      // Generate output PDF path
      final directory = path.dirname(pptFilePath);
      final filename = path.basenameWithoutExtension(pptFilePath);
      final pdfPath = path.join(directory, '$filename.pdf');
      
      // Check if PDF already exists
      final pdfFile = File(pdfPath);
      if (await pdfFile.exists()) {
        _logger.warning('PDF already exists, skipping: $pdfPath');
        return true;
      }
      
      // Create PowerShell script for conversion
      final powershellScript = _createPowerShellScript(pptFilePath, pdfPath);
      
      // Execute PowerShell script
      final result = await _executePowerShellScript(powershellScript);
      
      if (result) {
        // Verify PDF was created
        if (await pdfFile.exists()) {
          _logger.info('Successfully converted: $pptFilePath -> $pdfPath');
          return true;
        } else {
          _logger.severe('Conversion completed but PDF file not found: $pdfPath');
          return false;
        }
      } else {
        _logger.severe('PowerShell conversion failed for: $pptFilePath');
        return false;
      }
      
    } catch (e) {
      _logger.severe('Error during conversion of $pptFilePath: $e');
      return false;
    }
  }
  
  /// Creates a PowerShell script for PPT to PDF conversion
  String _createPowerShellScript(String inputPath, String outputPath) {
    // Escape paths for PowerShell
    final escapedInputPath = inputPath.replaceAll("'", "''");
    final escapedOutputPath = outputPath.replaceAll("'", "''");
    
    return '''
try {
    # Create PowerPoint application object
    \$powerpoint = New-Object -ComObject PowerPoint.Application
    \$powerpoint.Visible = [Microsoft.Office.Core.MsoTriState]::msoFalse
    
    # Open the presentation
    \$presentation = \$powerpoint.Presentations.Open('$escapedInputPath', \$true, \$true, \$false)
    
    # Export as PDF (ppSaveAsPDF = 32)
    \$presentation.ExportAsFixedFormat('$escapedOutputPath', 32)
    
    # Close presentation and quit PowerPoint
    \$presentation.Close()
    \$powerpoint.Quit()
    
    # Release COM objects
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject(\$presentation) | Out-Null
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject(\$powerpoint) | Out-Null
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
    
    Write-Output "SUCCESS: Conversion completed"
    exit 0
}
catch {
    Write-Error "FAILED: \$(\$_.Exception.Message)"
    
    # Cleanup in case of error
    try {
        if (\$presentation) { \$presentation.Close() }
        if (\$powerpoint) { \$powerpoint.Quit() }
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject(\$presentation) | Out-Null
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject(\$powerpoint) | Out-Null
    } catch {}
    
    exit 1
}
''';
  }
  
  /// Executes a PowerShell script and returns success status
  Future<bool> _executePowerShellScript(String script) async {
    try {
      // Create temporary script file
      final tempDir = Directory.systemTemp;
      final scriptFile = File(path.join(tempDir.path, 'ppt_conversion_${DateTime.now().millisecondsSinceEpoch}.ps1'));
      
      await scriptFile.writeAsString(script);
      
      try {
        // Execute PowerShell script
        final result = await Process.run(
          'powershell.exe',
          [
            '-ExecutionPolicy', 'Bypass',
            '-File', scriptFile.path
          ],
          runInShell: true,
        );
        
        _logger.info('PowerShell exit code: ${result.exitCode}');
        if (result.stdout.isNotEmpty) {
          _logger.info('PowerShell stdout: ${result.stdout}');
        }
        if (result.stderr.isNotEmpty) {
          _logger.warning('PowerShell stderr: ${result.stderr}');
        }
        
        return result.exitCode == 0;
        
      } finally {
        // Clean up temporary script file
        try {
          await scriptFile.delete();
        } catch (e) {
          _logger.warning('Failed to delete temporary script file: $e');
        }
      }
      
    } catch (e) {
      _logger.severe('Error executing PowerShell script: $e');
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
}
