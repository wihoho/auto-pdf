import 'package:flutter_test/flutter_test.dart';
import 'package:auto_pdf_converter/providers/app_state_provider.dart';
import 'package:auto_pdf_converter/services/file_watcher_service.dart';

void main() {
  group('Backfill Functionality Tests', () {
    test('AppStateProvider should handle new monitoring states', () {
      final appState = AppStateProvider();
      
      // Test initial state
      expect(appState.status, MonitoringStatus.idle);
      expect(appState.isScanning, false);
      expect(appState.isConverting, false);
      expect(appState.isMonitoring, false);
      
      // Test scanning state
      appState.setStatus(MonitoringStatus.scanning);
      expect(appState.status, MonitoringStatus.scanning);
      expect(appState.isScanning, true);
      expect(appState.isConverting, false);
      expect(appState.isMonitoring, false);
      
      // Test converting state
      appState.setStatus(MonitoringStatus.converting);
      expect(appState.status, MonitoringStatus.converting);
      expect(appState.isScanning, false);
      expect(appState.isConverting, true);
      expect(appState.isMonitoring, false);
      
      // Test monitoring state
      appState.setStatus(MonitoringStatus.monitoring);
      expect(appState.status, MonitoringStatus.monitoring);
      expect(appState.isScanning, false);
      expect(appState.isConverting, false);
      expect(appState.isMonitoring, true);
    });
    
    test('AppStateProvider should handle conversion progress', () {
      final appState = AppStateProvider();
      
      // Test initial progress
      expect(appState.totalFilesToConvert, 0);
      expect(appState.currentConversionIndex, 0);
      expect(appState.conversionProgress, '');
      
      // Test setting progress
      appState.setConversionProgress(5, 2);
      expect(appState.totalFilesToConvert, 5);
      expect(appState.currentConversionIndex, 2);
      expect(appState.conversionProgress, '2 of 5');
      
      // Test incrementing progress
      appState.incrementConversionProgress();
      expect(appState.currentConversionIndex, 3);
      expect(appState.conversionProgress, '3 of 5');
      
      // Test resetting progress
      appState.resetConversionProgress();
      expect(appState.totalFilesToConvert, 0);
      expect(appState.currentConversionIndex, 0);
      expect(appState.conversionProgress, '');
    });
    
    test('FileWatcherService should support PowerPoint file extensions', () {
      // Test PowerPoint file detection
      expect(FileWatcherService.isPowerPointFile('test.ppt'), true);
      expect(FileWatcherService.isPowerPointFile('test.pptx'), true);
      expect(FileWatcherService.isPowerPointFile('test.pptm'), true);
      expect(FileWatcherService.isPowerPointFile('test.PPT'), true);
      expect(FileWatcherService.isPowerPointFile('test.PPTX'), true);
      expect(FileWatcherService.isPowerPointFile('test.PPTM'), true);
      
      // Test non-PowerPoint files
      expect(FileWatcherService.isPowerPointFile('test.pdf'), false);
      expect(FileWatcherService.isPowerPointFile('test.doc'), false);
      expect(FileWatcherService.isPowerPointFile('test.txt'), false);
      expect(FileWatcherService.isPowerPointFile('test'), false);
    });
  });
}
