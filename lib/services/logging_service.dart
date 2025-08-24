import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:logging/logging.dart';

class LoggingService {
  static final LoggingService _instance = LoggingService._internal();
  static LoggingService get instance => _instance;
  
  LoggingService._internal();
  
  final Logger _logger = Logger('AutoPdfConverter');
  final List<String> _logs = [];
  File? _logFile;
  
  List<String> get logs => List.unmodifiable(_logs);
  
  Future<void> initialize() async {
    try {
      // Create logs directory in the app's directory
      final appDir = Directory.current;
      final logsDir = Directory(path.join(appDir.path, 'logs'));
      
      if (!await logsDir.exists()) {
        await logsDir.create(recursive: true);
      }
      
      // Create log file with timestamp
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      _logFile = File(path.join(logsDir.path, 'app_$timestamp.log'));
      
      _logger.info('Logging service initialized');
    } catch (e) {
      _logger.severe('Failed to initialize logging service: $e');
    }
  }
  
  void addLog(String message) {
    final timestamp = DateTime.now().toString().substring(0, 19);
    final logEntry = '[$timestamp] $message';
    
    _logs.insert(0, logEntry);
    
    // Keep only the last 1000 log entries in memory
    if (_logs.length > 1000) {
      _logs.removeLast();
    }
    
    // Write to file if available
    _writeToFile(logEntry);
  }
  
  void _writeToFile(String logEntry) {
    try {
      _logFile?.writeAsStringSync('$logEntry\n', mode: FileMode.append);
    } catch (e) {
      _logger.warning('Failed to write to log file: $e');
    }
  }
  
  void info(String message) {
    _logger.info(message);
    addLog('INFO: $message');
  }
  
  void warning(String message) {
    _logger.warning(message);
    addLog('WARNING: $message');
  }
  
  void error(String message, [Object? error]) {
    _logger.severe(message, error);
    addLog('ERROR: $message${error != null ? ' - $error' : ''}');
  }
  
  void clearLogs() {
    _logs.clear();
  }
}
