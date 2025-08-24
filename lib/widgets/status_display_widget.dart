import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';

class StatusDisplayWidget extends StatelessWidget {
  const StatusDisplayWidget({super.key});

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
                      Icons.info_outline,
                      color: _getStatusColor(appState.status),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Status',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Current status
                _buildStatusRow(
                  context,
                  'Current Status',
                  _getStatusText(appState.status),
                  _getStatusColor(appState.status),
                ),
                
                const SizedBox(height: 12),
                
                // Files converted
                _buildStatusRow(
                  context,
                  'Files Converted',
                  appState.convertedFilesCount.toString(),
                  Colors.blue,
                ),
                
                const SizedBox(height: 12),
                
                // Watched folder
                _buildStatusRow(
                  context,
                  'Watched Folder',
                  appState.hasSelectedFolder ? 'Selected' : 'None',
                  appState.hasSelectedFolder ? Colors.green : Colors.grey,
                ),

                // Conversion progress (only show during converting)
                if (appState.isConverting && appState.conversionProgress.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildStatusRow(
                    context,
                    'Conversion Progress',
                    appState.conversionProgress,
                    Colors.orange,
                  ),
                ],
                
                // Error display
                if (appState.lastError != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      border: Border.all(color: Colors.red.shade200),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 16,
                              color: Colors.red.shade700,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Last Error:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          appState.lastError!,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.red.shade600,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
                
                const SizedBox(height: 16),
                
                // Status indicator with animation
                Center(
                  child: _buildStatusIndicator(appState.status),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusRow(BuildContext context, String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusIndicator(MonitoringStatus status) {
    switch (status) {
      case MonitoringStatus.scanning:
        return _buildAnimatedIndicator(Colors.blue, 'Scanning');
      case MonitoringStatus.converting:
        return _buildAnimatedIndicator(Colors.orange, 'Converting');
      case MonitoringStatus.monitoring:
        return _buildAnimatedIndicator(Colors.green, 'Monitoring');
      case MonitoringStatus.error:
        return _buildStaticIndicator(Colors.red, 'Error');
      case MonitoringStatus.idle:
      default:
        return _buildStaticIndicator(Colors.grey, 'Idle');
    }
  }

  Widget _buildAnimatedIndicator(Color color, String text) {
    return Column(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildStaticIndicator(Color color, String text) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getStatusIcon(text),
            color: Colors.white,
            size: 16,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'error':
        return Icons.error;
      case 'idle':
        return Icons.pause;
      default:
        return Icons.check;
    }
  }

  Color _getStatusColor(MonitoringStatus status) {
    switch (status) {
      case MonitoringStatus.scanning:
        return Colors.blue;
      case MonitoringStatus.converting:
        return Colors.orange;
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
      case MonitoringStatus.scanning:
        return 'Scanning';
      case MonitoringStatus.converting:
        return 'Converting';
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
