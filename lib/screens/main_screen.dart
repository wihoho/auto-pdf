import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../services/file_watcher_service.dart';
import '../services/logging_service.dart';
import '../widgets/folder_selection_widget.dart';
import '../widgets/monitoring_control_widget.dart';
import '../widgets/status_display_widget.dart';
import '../widgets/log_display_widget.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
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
      // Success message is already logged by the file watcher service
    };
    
    _fileWatcherService.onConversionError = (error) {
      appState.setError(error);
    };
    
    _fileWatcherService.onLog = (message) {
      appState.addLog(message);
    };
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
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showAboutDialog,
            tooltip: 'About',
          ),
        ],
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
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Folder selection
              FolderSelectionWidget(),
              
              SizedBox(height: 16),
              
              // Monitoring controls and status
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: MonitoringControlWidget(),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: StatusDisplayWidget(),
                  ),
                ],
              ),
              
              SizedBox(height: 16),
              
              // Log display
              Expanded(
                child: LogDisplayWidget(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.picture_as_pdf, color: Colors.blue),
            SizedBox(width: 8),
            Text('About Auto PDF Converter'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version 1.0.0',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Automatically converts PowerPoint and Word documents to PDF format when they are added to a monitored folder.',
            ),
            SizedBox(height: 16),
            Text(
              'Requirements:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('• Microsoft PowerPoint and/or Word installed'),
            Text('• Windows operating system'),
            SizedBox(height: 16),
            Text(
              'How to use:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('1. Select a folder to monitor'),
            Text('2. Click "Start Monitoring"'),
            Text('3. Add PowerPoint (.ppt, .pptx) or Word (.doc, .docx) files to the folder'),
            Text('4. PDFs will be created automatically'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
