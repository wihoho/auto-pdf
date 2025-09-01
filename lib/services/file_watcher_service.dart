import 'dart:io';
import 'dart:async';
import 'package:path/path.dart' as path;
import 'package:watcher/watcher.dart';
import 'package:logging/logging.dart';

import 'conversion_service.dart';

class FileWatcherService {
  final Logger _logger = Logger('FileWatcherService');
  final ConversionService _conversionService = ConversionService();
  
  DirectoryWatcher? _watcher;
  StreamSubscription? _subscription;
  String? _watchedDirectory;
  
  // Callback functions
  Function(String)? onFileConverted;
  Function(String)? onConversionError;
  Function(String)? onLog;
  Function(int total, int current)? onProgressUpdate;
  Function()? onScanningStarted;
  Function()? onConvertingStarted;
  Function()? onConvertingCompleted;
  
  bool get isWatching => _watcher != null && _subscription != null;
  String? get watchedDirectory => _watchedDirectory;
  
  /// Starts watching the specified directory for new PowerPoint files
  Future<bool> startWatching(String directoryPath) async {
    try {
      // Stop any existing watcher
      await stopWatching();
      
      // Validate directory
      final directory = Directory(directoryPath);
      if (!await directory.exists()) {
        _logger.severe('Directory does not exist: $directoryPath');
        onConversionError?.call('Directory does not exist: $directoryPath');
        return false;
      }
      
      // Check if PowerPoint is installed
      final isPowerPointAvailable = await _conversionService.isPowerPointInstalled();
      if (!isPowerPointAvailable) {
        _logger.warning('Microsoft PowerPoint may not be installed or accessible');
        onLog?.call('WARNING: Microsoft PowerPoint may not be installed. Conversion may fail.');
      }
      
      _logger.info('Starting to watch directory: $directoryPath');
      onLog?.call('Started monitoring: $directoryPath');
      
      // Create directory watcher
      _watcher = DirectoryWatcher(directoryPath);
      _watchedDirectory = directoryPath;
      
      // Subscribe to file system events
      _subscription = _watcher!.events.listen(
        _handleFileSystemEvent,
        onError: (error) {
          _logger.severe('File watcher error: $error');
          onConversionError?.call('File watcher error: $error');
        },
        onDone: () {
          _logger.info('File watcher stream closed');
          onLog?.call('File monitoring stopped');
        },
      );
      
      return true;
      
    } catch (e) {
      _logger.severe('Error starting file watcher: $e');
      onConversionError?.call('Error starting file watcher: $e');
      return false;
    }
  }
  
  /// Stops watching the directory
  Future<void> stopWatching() async {
    try {
      if (_subscription != null) {
        await _subscription!.cancel();
        _subscription = null;
      }
      
      _watcher = null;
      _watchedDirectory = null;
      
      _logger.info('File watching stopped');
      onLog?.call('File monitoring stopped');
      
    } catch (e) {
      _logger.warning('Error stopping file watcher: $e');
    }
  }
  
  /// Handles file system events
  void _handleFileSystemEvent(WatchEvent event) {
    try {
      final filePath = event.path;
      final fileName = path.basename(filePath);
      
      _logger.fine('File system event: ${event.type} - $filePath');
      
      // Only process file additions
      if (event.type != ChangeType.ADD) {
        return;
      }
      
      // Check if it's a PowerPoint file
      if (!_isPowerPointFile(fileName)) {
        return;
      }
      
      _logger.info('New PowerPoint file detected: $fileName');
      onLog?.call('New PowerPoint file detected: $fileName');
      
      // Process the file with a slight delay to ensure it's fully written
      Timer(const Duration(seconds: 2), () {
        _processNewFile(filePath);
      });
      
    } catch (e) {
      _logger.severe('Error handling file system event: $e');
      onConversionError?.call('Error processing file system event: $e');
    }
  }
  
  /// Processes a new PowerPoint file for conversion
  Future<void> _processNewFile(String filePath) async {
    try {
      final fileName = path.basename(filePath);
      
      // Verify file still exists and is accessible
      final file = File(filePath);
      if (!await file.exists()) {
        _logger.warning('File no longer exists: $filePath');
        return;
      }
      
      // Wait a bit more to ensure file is not being written to
      await _waitForFileStability(filePath);
      
      _logger.info('Starting conversion of: $fileName');
      onLog?.call('Converting: $fileName');
      
      // Attempt conversion
      final success = await _conversionService.convertPptToPdf(filePath);
      
      if (success) {
        _logger.info('Successfully converted: $fileName');
        onLog?.call('Successfully converted: $fileName');
        onFileConverted?.call(filePath);
      } else {
        _logger.severe('Failed to convert: $fileName');
        onConversionError?.call('Failed to convert: $fileName');
      }
      
    } catch (e) {
      _logger.severe('Error processing file $filePath: $e');
      onConversionError?.call('Error processing file: $e');
    }
  }
  
  /// Waits for file to be stable (not being written to)
  Future<void> _waitForFileStability(String filePath) async {
    const maxAttempts = 10;
    const delayBetweenAttempts = Duration(milliseconds: 500);
    
    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        final file = File(filePath);
        final stat1 = await file.stat();
        
        await Future.delayed(delayBetweenAttempts);
        
        final stat2 = await file.stat();
        
        // If file size hasn't changed, assume it's stable
        if (stat1.size == stat2.size && stat1.modified == stat2.modified) {
          return;
        }
        
      } catch (e) {
        _logger.warning('Error checking file stability: $e');
        break;
      }
    }
    
    // Additional safety delay
    await Future.delayed(const Duration(seconds: 1));
  }
  
  /// Checks if a file is a PowerPoint file based on extension
  static bool isPowerPointFile(String fileName) {
    final extension = path.extension(fileName).toLowerCase();
    return extension == '.ppt' || extension == '.pptx' || extension == '.pptm';
  }

  /// Private wrapper for the static method
  bool _isPowerPointFile(String fileName) {
    return isPowerPointFile(fileName);
  }
  
  /// Scans directory and converts PowerPoint files that don't have corresponding PDFs
  Future<void> scanAndConvertExistingFiles(String directoryPath) async {
    try {
      _logger.info('Starting scan of directory: $directoryPath');
      onScanningStarted?.call();
      onLog?.call('Scanning folder for existing files...');

      final directory = Directory(directoryPath);
      if (!await directory.exists()) {
        _logger.severe('Directory does not exist: $directoryPath');
        onConversionError?.call('Directory does not exist: $directoryPath');
        return;
      }

      // Get all files in the directory
      final allFiles = await directory.list().toList();
      final List<File> pptFiles = [];
      final Set<String> allFileBasenames = {};

      // Separate PowerPoint files and collect all file basenames
      for (final entity in allFiles) {
        if (entity is File) {
          final filePath = entity.path;
          final extension = path.extension(filePath).toLowerCase();
          final basename = path.basenameWithoutExtension(filePath);

          // Add to set for quick lookup (e.g., 'report.pdf')
          allFileBasenames.add('$basename${extension}');

          // Collect PowerPoint files
          if (extension == '.ppt' || extension == '.pptx' || extension == '.pptm') {
            pptFiles.add(entity);
          }
        }
      }

      // Identify PowerPoint files that don't have corresponding PDFs
      final List<File> filesToConvert = [];
      for (final pptFile in pptFiles) {
        final basename = path.basenameWithoutExtension(pptFile.path);
        final correspondingPdf = '$basename.pdf';

        if (!allFileBasenames.contains(correspondingPdf)) {
          filesToConvert.add(pptFile);
        }
      }

      _logger.info('Scan complete. Found ${pptFiles.length} PowerPoint files, ${filesToConvert.length} need conversion');
      onLog?.call('Found ${pptFiles.length} PowerPoint files, ${filesToConvert.length} need conversion');

      // Process conversion queue if there are files to convert
      if (filesToConvert.isNotEmpty) {
        await _processConversionQueue(filesToConvert);
      } else {
        onLog?.call('All PowerPoint files already have corresponding PDFs');
      }

    } catch (e) {
      _logger.severe('Error scanning existing files: $e');
      onConversionError?.call('Error scanning existing files: $e');
    }
  }

  /// Manually processes all existing PowerPoint files in the watched directory
  Future<void> processExistingFiles() async {
    if (_watchedDirectory == null) return;

    try {
      final directory = Directory(_watchedDirectory!);
      final files = await directory.list().toList();

      for (final entity in files) {
        if (entity is File && _isPowerPointFile(entity.path)) {
          final fileName = path.basename(entity.path);
          _logger.info('Processing existing file: $fileName');
          onLog?.call('Processing existing file: $fileName');

          await _processNewFile(entity.path);
        }
      }

    } catch (e) {
      _logger.severe('Error processing existing files: $e');
      onConversionError?.call('Error processing existing files: $e');
    }
  }

  /// Processes a queue of files for conversion with progress tracking
  Future<void> _processConversionQueue(List<File> filesToConvert) async {
    final totalToConvert = filesToConvert.length;
    int convertedCount = 0;

    _logger.info('Starting conversion of $totalToConvert files');
    onConvertingStarted?.call();
    onProgressUpdate?.call(totalToConvert, convertedCount);
    onLog?.call('Converting $convertedCount of $totalToConvert existing files...');

    for (final file in filesToConvert) {
      try {
        final fileName = path.basename(file.path);
        _logger.info('Converting file ${convertedCount + 1} of $totalToConvert: $fileName');
        onLog?.call('Converting ${convertedCount + 1} of $totalToConvert: $fileName');

        // Wait for file stability before conversion
        await _waitForFileStability(file.path);

        // Attempt conversion
        final success = await _conversionService.convertPptToPdf(file.path);

        if (success) {
          convertedCount++;
          _logger.info('Successfully converted: $fileName');
          onLog?.call('Successfully converted: $fileName');
          onFileConverted?.call(file.path);
        } else {
          _logger.severe('Failed to convert: $fileName');
          onConversionError?.call('Failed to convert: $fileName');
        }

        // Update progress after each file
        onProgressUpdate?.call(totalToConvert, convertedCount);

      } catch (e) {
        _logger.severe('Error converting file ${file.path}: $e');
        onConversionError?.call('Error converting file: $e');
      }
    }

    _logger.info('Conversion queue complete. Successfully converted $convertedCount of $totalToConvert files');
    onLog?.call('Initial conversion complete. Successfully converted $convertedCount of $totalToConvert files');
    onConvertingCompleted?.call();
  }
}
