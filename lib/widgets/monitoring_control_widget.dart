import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../services/file_watcher_service.dart';

class MonitoringControlWidget extends StatelessWidget {
  const MonitoringControlWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      appState.isMonitoring ? Icons.play_circle : Icons.pause_circle,
                      color: appState.isMonitoring ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Monitoring Control',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Start/Stop buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: appState.hasSelectedFolder && !appState.isMonitoring
                            ? () => _startMonitoring(context)
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
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: appState.isMonitoring
                            ? () => _stopMonitoring(context)
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
                
                // Process existing files button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: appState.hasSelectedFolder && !appState.isMonitoring
                        ? () => _processExistingFiles(context)
                        : null,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Process Existing Files'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Help text
                Text(
                  appState.hasSelectedFolder
                      ? 'Click "Start Monitoring" to begin watching for new PowerPoint files.'
                      : 'Please select a folder first.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _startMonitoring(BuildContext context) async {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    final fileWatcherService = Provider.of<FileWatcherService>(context, listen: false);
    
    if (appState.selectedFolderPath == null) {
      _showErrorSnackBar(context, 'Please select a folder first');
      return;
    }
    
    try {
      appState.setStatus(MonitoringStatus.monitoring);
      appState.addLog('Starting monitoring...');
      
      final success = await fileWatcherService.startWatching(appState.selectedFolderPath!);
      
      if (success) {
        appState.addLog('Monitoring started successfully');
        _showSuccessSnackBar(context, 'Monitoring started');
      } else {
        appState.setError('Failed to start monitoring');
        _showErrorSnackBar(context, 'Failed to start monitoring');
      }
    } catch (e) {
      appState.setError('Error starting monitoring: $e');
      _showErrorSnackBar(context, 'Error starting monitoring: $e');
    }
  }

  Future<void> _stopMonitoring(BuildContext context) async {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    final fileWatcherService = Provider.of<FileWatcherService>(context, listen: false);
    
    try {
      await fileWatcherService.stopWatching();
      appState.setStatus(MonitoringStatus.idle);
      appState.addLog('Monitoring stopped');
      _showInfoSnackBar(context, 'Monitoring stopped');
    } catch (e) {
      appState.setError('Error stopping monitoring: $e');
      _showErrorSnackBar(context, 'Error stopping monitoring: $e');
    }
  }

  Future<void> _processExistingFiles(BuildContext context) async {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    final fileWatcherService = Provider.of<FileWatcherService>(context, listen: false);
    
    if (appState.selectedFolderPath == null) {
      _showErrorSnackBar(context, 'Please select a folder first');
      return;
    }
    
    try {
      appState.addLog('Processing existing PowerPoint files...');
      _showInfoSnackBar(context, 'Processing existing files...');
      
      // Temporarily set up the watcher to process existing files
      await fileWatcherService.startWatching(appState.selectedFolderPath!);
      await fileWatcherService.processExistingFiles();
      await fileWatcherService.stopWatching();
      
      appState.addLog('Finished processing existing files');
      _showSuccessSnackBar(context, 'Finished processing existing files');
    } catch (e) {
      appState.setError('Error processing existing files: $e');
      _showErrorSnackBar(context, 'Error processing existing files: $e');
    }
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void _showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
