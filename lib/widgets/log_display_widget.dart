import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';

class LogDisplayWidget extends StatefulWidget {
  const LogDisplayWidget({super.key});

  @override
  State<LogDisplayWidget> createState() => _LogDisplayWidgetState();
}

class _LogDisplayWidgetState extends State<LogDisplayWidget> {
  final ScrollController _scrollController = ScrollController();
  bool _autoScroll = true;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        // Auto-scroll to top when new logs are added
        if (_autoScroll && appState.logs.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        }

        return Card(
          elevation: 2,
          child: Column(
            children: [
              // Header
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
                    
                    // Auto-scroll toggle
                    Row(
                      children: [
                        Icon(
                          Icons.vertical_align_top,
                          size: 16,
                          color: _autoScroll ? Colors.blue : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Switch(
                          value: _autoScroll,
                          onChanged: (value) {
                            setState(() {
                              _autoScroll = value;
                            });
                          },
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ],
                    ),
                    
                    const SizedBox(width: 8),
                    
                    // Clear logs button
                    IconButton(
                      icon: const Icon(Icons.clear_all),
                      onPressed: appState.logs.isNotEmpty
                          ? () => _showClearLogsDialog(context, appState)
                          : null,
                      tooltip: 'Clear logs',
                    ),
                    
                    // Copy logs button
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: appState.logs.isNotEmpty
                          ? () => _copyLogsToClipboard(context, appState)
                          : null,
                      tooltip: 'Copy logs to clipboard',
                    ),
                  ],
                ),
              ),
              
              // Log content
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: appState.logs.isEmpty
                      ? _buildEmptyState()
                      : _buildLogList(appState.logs),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No activity yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Activity logs will appear here when you start monitoring',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLogList(List<String> logs) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8),
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        return _buildLogItem(log, index);
      },
    );
  }

  Widget _buildLogItem(String log, int index) {
    final isError = log.contains('ERROR:');
    final isWarning = log.contains('WARNING:');
    final isSuccess = log.contains('Successfully converted:');
    
    Color backgroundColor;
    Color textColor;
    IconData icon;
    
    if (isError) {
      backgroundColor = Colors.red.shade50;
      textColor = Colors.red.shade700;
      icon = Icons.error_outline;
    } else if (isWarning) {
      backgroundColor = Colors.orange.shade50;
      textColor = Colors.orange.shade700;
      icon = Icons.warning_outlined;
    } else if (isSuccess) {
      backgroundColor = Colors.green.shade50;
      textColor = Colors.green.shade700;
      icon = Icons.check_circle_outline;
    } else {
      backgroundColor = Colors.transparent;
      textColor = Colors.grey.shade700;
      icon = Icons.info_outline;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
        border: isError || isWarning || isSuccess
            ? Border.all(color: textColor.withOpacity(0.3))
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: textColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              log,
              style: TextStyle(
                fontSize: 12,
                color: textColor,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearLogsDialog(BuildContext context, AppStateProvider appState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Logs'),
        content: const Text('Are you sure you want to clear all activity logs?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              appState.clearLogs();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Logs cleared'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _copyLogsToClipboard(BuildContext context, AppStateProvider appState) {
    final logsText = appState.logs.join('\n');
    Clipboard.setData(ClipboardData(text: logsText));
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logs copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
