import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';

class FolderSelectionWidget extends StatelessWidget {
  const FolderSelectionWidget({super.key});

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
                  child: Row(
                    children: [
                      const Icon(Icons.folder_outlined, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          appState.selectedFolderPath ?? 'No folder selected',
                          style: TextStyle(
                            color: appState.hasSelectedFolder 
                                ? Colors.black87 
                                : Colors.grey.shade600,
                            fontFamily: 'monospace',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (appState.hasSelectedFolder)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: appState.isMonitoring 
                              ? null 
                              : () => appState.setSelectedFolder(null),
                          tooltip: 'Clear selection',
                        ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Browse button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: appState.isMonitoring ? null : () => _selectFolder(context),
                    icon: const Icon(Icons.folder_open),
                    label: const Text('Browse for Folder'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Help text
                Text(
                  'Select a folder to monitor for new PowerPoint files (.ppt, .pptx). '
                  'The app will automatically convert them to PDF when detected.',
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

  Future<void> _selectFolder(BuildContext context) async {
    try {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Select folder to monitor for PowerPoint files',
        lockParentWindow: true,
      );

      if (selectedDirectory != null) {
        final appState = Provider.of<AppStateProvider>(context, listen: false);
        appState.setSelectedFolder(selectedDirectory);
        appState.addLog('Selected folder: $selectedDirectory');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting folder: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
