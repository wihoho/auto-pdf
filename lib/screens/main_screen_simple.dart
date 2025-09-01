import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/app_state_provider.dart';
import '../services/file_watcher_service.dart';
import '../services/logging_service.dart';

class MainScreenSimple extends StatefulWidget {
  const MainScreenSimple({super.key});

  @override
  State<MainScreenSimple> createState() => _MainScreenSimpleState();
}

class _MainScreenSimpleState extends State<MainScreenSimple> {
  late FileWatcherService _fileWatcherService;
  late LoggingService _loggingService;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  void _initializeServices() {
    _fileWatcherService = Provider.of<FileWatcherService>(context, listen: false);
    _loggingService = Provider.of<LoggingService>(context, listen: false);
    
    // Initialize logging service
    _loggingService.initialize();
    
    // Set up file watcher callbacks
    _setupFileWatcherCallbacks();
    
    // Log app startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<AppStateProvider>(context, listen: false);
      appState.addLog('Auto PDF Converter started');
      _loggingService.info('Application started');
    });
  }

  void _setupFileWatcherCallbacks() {
    final appState = Provider.of<AppStateProvider>(context, listen: false);

    _fileWatcherService.onFileConverted = (filePath) {
      appState.incrementConvertedFiles();
      appState.addLog('Successfully converted: ${_getFileName(filePath)}');
    };

    _fileWatcherService.onConversionError = (error) {
      appState.setError(error);
    };

    _fileWatcherService.onLog = (message) {
      appState.addLog(message);
    };

    // New callbacks for backfill process
    _fileWatcherService.onScanningStarted = () {
      appState.setStatus(MonitoringStatus.scanning);
    };

    _fileWatcherService.onConvertingStarted = () {
      appState.setStatus(MonitoringStatus.converting);
    };

    _fileWatcherService.onProgressUpdate = (total, current) {
      appState.setConversionProgress(total, current);
    };

    _fileWatcherService.onConvertingCompleted = () {
      appState.resetConversionProgress();
    };
  }

  String _getFileName(String filePath) {
    return filePath.split('\\').last.split('/').last;
  }

  @override
  void dispose() {
    _fileWatcherService.stopWatching();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.picture_as_pdf, color: Colors.white),
            SizedBox(width: 8),
            Text('Auto PDF Converter'),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Consumer<AppStateProvider>(
            builder: (context, appState, child) {
              return Column(
                children: [
                  // Folder selection card
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.folder, color: Colors.blue),
                              const SizedBox(width: 8),
                              Text(
                                'Folder Selection',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Current folder display
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey.shade50,
                            ),
                            child: Text(
                              appState.selectedFolderPath ?? 'No folder selected',
                              style: TextStyle(
                                color: appState.hasSelectedFolder 
                                    ? Colors.black87 
                                    : Colors.grey.shade600,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                          
                          const SizedBox(width: 16),
                          
                          // Browse button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: appState.isMonitoring ? null : () => _selectFolder(appState),
                              icon: const Icon(Icons.folder_open),
                              label: const Text('Browse for Folder'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Control buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: appState.hasSelectedFolder && !appState.isMonitoring
                              ? () => _startMonitoring(appState)
                              : null,
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Start Monitoring'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: appState.isMonitoring
                              ? () => _stopMonitoring(appState)
                              : null,
                          icon: const Icon(Icons.stop),
                          label: const Text('Stop Monitoring'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Status display
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text(
                                'Status',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getStatusText(appState.status),
                                style: TextStyle(
                                  color: _getStatusColor(appState.status),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                'Files Converted',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                appState.convertedFilesCount.toString(),
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Log display
                  Expanded(
                    child: Card(
                      elevation: 2,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.list_alt, color: Colors.blue),
                                const SizedBox(width: 8),
                                Text(
                                  'Activity Log',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Icons.clear_all),
                                  onPressed: appState.logs.isNotEmpty
                                      ? () => appState.clearLogs()
                                      : null,
                                  tooltip: 'Clear logs',
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: appState.logs.isEmpty
                                ? const Center(
                                    child: Text(
                                      'No activity yet\nActivity logs will appear here when you start monitoring',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.all(8),
                                    itemCount: appState.logs.length,
                                    itemBuilder: (context, index) {
                                      final log = appState.logs[index];
                                      return Container(
                                        margin: const EdgeInsets.only(bottom: 4),
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: log.contains('ERROR:') 
                                              ? Colors.red.shade50
                                              : log.contains('Successfully converted:')
                                                  ? Colors.green.shade50
                                                  : Colors.transparent,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          log,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: log.contains('ERROR:') 
                                                ? Colors.red.shade700
                                                : log.contains('Successfully converted:')
                                                    ? Colors.green.shade700
                                                    : Colors.grey.shade700,
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _selectFolder(AppStateProvider appState) async {
    try {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Select folder to monitor for PowerPoint files',
        lockParentWindow: true,
      );

      if (selectedDirectory != null) {
        appState.setSelectedFolder(selectedDirectory);
        appState.addLog('Selected folder: $selectedDirectory');

        // Immediately start scanning for existing files
        await _scanAndConvertExistingFiles(appState, selectedDirectory);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting folder: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _scanAndConvertExistingFiles(AppStateProvider appState, String directoryPath) async {
    try {
      appState.resetConversionProgress();

      // Perform the scan and conversion
      await _fileWatcherService.scanAndConvertExistingFiles(directoryPath);

      appState.addLog('Initial scan and conversion complete');

      // After backfill is complete, start normal monitoring
      await _startMonitoring(appState);

    } catch (e) {
      appState.setError('Error during initial scan: $e');
    }
  }

  Future<void> _startMonitoring(AppStateProvider appState) async {
    if (appState.selectedFolderPath == null) return;

    try {
      appState.setStatus(MonitoringStatus.monitoring);
      appState.addLog('Starting monitoring...');

      final success = await _fileWatcherService.startWatching(appState.selectedFolderPath!);

      if (success) {
        appState.addLog('Monitoring started successfully');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Monitoring started'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        appState.setError('Failed to start monitoring');
      }
    } catch (e) {
      appState.setError('Error starting monitoring: $e');
    }
  }

  Future<void> _stopMonitoring(AppStateProvider appState) async {
    try {
      await _fileWatcherService.stopWatching();
      appState.setStatus(MonitoringStatus.idle);
      appState.addLog('Monitoring stopped');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Monitoring stopped'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      appState.setError('Error stopping monitoring: $e');
    }
  }

  Color _getStatusColor(MonitoringStatus status) {
    switch (status) {
      case MonitoringStatus.monitoring:
        return Colors.green;
      case MonitoringStatus.error:
        return Colors.red;
      case MonitoringStatus.idle:
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(MonitoringStatus status) {
    switch (status) {
      case MonitoringStatus.monitoring:
        return 'Monitoring';
      case MonitoringStatus.error:
        return 'Error';
      case MonitoringStatus.idle:
      default:
        return 'Idle';
    }
  }
}
