import 'package:flutter/foundation.dart';

enum MonitoringStatus {
  idle,
  scanning,
  converting,
  monitoring,
  error,
}

class AppStateProvider extends ChangeNotifier {
  String? _selectedFolderPath;
  MonitoringStatus _status = MonitoringStatus.idle;
  List<String> _logs = [];
  int _convertedFilesCount = 0;
  String? _lastError;

  // Backfill conversion progress tracking
  int _totalFilesToConvert = 0;
  int _currentConversionIndex = 0;

  // Getters
  String? get selectedFolderPath => _selectedFolderPath;
  MonitoringStatus get status => _status;
  List<String> get logs => List.unmodifiable(_logs);
  int get convertedFilesCount => _convertedFilesCount;
  String? get lastError => _lastError;
  int get totalFilesToConvert => _totalFilesToConvert;
  int get currentConversionIndex => _currentConversionIndex;

  bool get isMonitoring => _status == MonitoringStatus.monitoring;
  bool get isScanning => _status == MonitoringStatus.scanning;
  bool get isConverting => _status == MonitoringStatus.converting;
  bool get hasSelectedFolder => _selectedFolderPath != null;

  String get conversionProgress {
    if (_totalFilesToConvert == 0) return '';
    return '$_currentConversionIndex of $_totalFilesToConvert';
  }

  // Setters
  void setSelectedFolder(String? path) {
    _selectedFolderPath = path;
    notifyListeners();
  }

  void setStatus(MonitoringStatus status) {
    _status = status;
    _lastError = null; // Clear error when status changes
    notifyListeners();
  }

  void setError(String error) {
    _lastError = error;
    _status = MonitoringStatus.error;
    addLog('ERROR: $error');
    notifyListeners();
  }

  void addLog(String message) {
    final timestamp = DateTime.now().toString().substring(0, 19);
    _logs.insert(0, '[$timestamp] $message');
    
    // Keep only the last 100 log entries
    if (_logs.length > 100) {
      _logs = _logs.take(100).toList();
    }
    
    notifyListeners();
  }

  void incrementConvertedFiles() {
    _convertedFilesCount++;
    notifyListeners();
  }

  void setConversionProgress(int total, int current) {
    _totalFilesToConvert = total;
    _currentConversionIndex = current;
    notifyListeners();
  }

  void incrementConversionProgress() {
    _currentConversionIndex++;
    notifyListeners();
  }

  void resetConversionProgress() {
    _totalFilesToConvert = 0;
    _currentConversionIndex = 0;
    notifyListeners();
  }

  void clearLogs() {
    _logs.clear();
    notifyListeners();
  }

  void reset() {
    _selectedFolderPath = null;
    _status = MonitoringStatus.idle;
    _logs.clear();
    _convertedFilesCount = 0;
    _lastError = null;
    _totalFilesToConvert = 0;
    _currentConversionIndex = 0;
    notifyListeners();
  }
}
