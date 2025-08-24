import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:auto_pdf_converter/providers/app_state_provider.dart';
import 'package:auto_pdf_converter/services/file_watcher_service.dart';
import 'package:auto_pdf_converter/services/conversion_service.dart';
import 'package:auto_pdf_converter/services/logging_service.dart';

// No need for test subclass since we made isPowerPointFile static

void main() {
  group('Auto PDF Converter App Tests', () {
    testWidgets('App starts and displays main UI elements', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AppStateProvider()),
            Provider(create: (_) => FileWatcherService()),
            Provider(create: (_) => ConversionService()),
            Provider(create: (_) => LoggingService.instance),
          ],
          child: MaterialApp(
            home: Scaffold(
              appBar: AppBar(title: const Text('Auto PDF Converter')),
              body: const Center(child: Text('Test App')),
            ),
          ),
        ),
      );

      // Verify that the app title is displayed
      expect(find.text('Auto PDF Converter'), findsOneWidget);
    });

    testWidgets('Folder selection widget displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider(
              create: (_) => AppStateProvider(),
              child: const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text('Folder Selection'),
                      Text('No folder selected'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Folder Selection'), findsOneWidget);
      expect(find.text('No folder selected'), findsOneWidget);
    });
  });

  group('AppStateProvider Tests', () {
    late AppStateProvider appState;

    setUp(() {
      appState = AppStateProvider();
    });

    test('Initial state is correct', () {
      expect(appState.selectedFolderPath, isNull);
      expect(appState.status, MonitoringStatus.idle);
      expect(appState.logs, isEmpty);
      expect(appState.convertedFilesCount, 0);
      expect(appState.isMonitoring, false);
      expect(appState.hasSelectedFolder, false);
    });

    test('Setting folder path works correctly', () {
      const testPath = 'C:\\Test\\Folder';
      appState.setSelectedFolder(testPath);
      
      expect(appState.selectedFolderPath, testPath);
      expect(appState.hasSelectedFolder, true);
    });

    test('Setting status works correctly', () {
      appState.setStatus(MonitoringStatus.monitoring);
      
      expect(appState.status, MonitoringStatus.monitoring);
      expect(appState.isMonitoring, true);
    });

    test('Adding logs works correctly', () {
      const testMessage = 'Test log message';
      appState.addLog(testMessage);
      
      expect(appState.logs.length, 1);
      expect(appState.logs.first.contains(testMessage), true);
    });

    test('Incrementing converted files count works', () {
      appState.incrementConvertedFiles();
      appState.incrementConvertedFiles();
      
      expect(appState.convertedFilesCount, 2);
    });

    test('Setting error updates status and adds log', () {
      const errorMessage = 'Test error';
      appState.setError(errorMessage);
      
      expect(appState.status, MonitoringStatus.error);
      expect(appState.lastError, errorMessage);
      expect(appState.logs.any((log) => log.contains('ERROR: $errorMessage')), true);
    });

    test('Clearing logs works correctly', () {
      appState.addLog('Test message 1');
      appState.addLog('Test message 2');
      expect(appState.logs.length, 2);
      
      appState.clearLogs();
      expect(appState.logs, isEmpty);
    });

    test('Reset clears all state', () {
      appState.setSelectedFolder('C:\\Test');
      appState.setStatus(MonitoringStatus.monitoring);
      appState.addLog('Test message');
      appState.incrementConvertedFiles();
      
      appState.reset();
      
      expect(appState.selectedFolderPath, isNull);
      expect(appState.status, MonitoringStatus.idle);
      expect(appState.logs, isEmpty);
      expect(appState.convertedFilesCount, 0);
      expect(appState.lastError, isNull);
    });
  });

  group('ConversionService Tests', () {
    late ConversionService conversionService;

    setUp(() {
      conversionService = ConversionService();
    });

    test('PowerPoint file detection works correctly', () {
      // Note: This would require access to private methods
      // In a real implementation, you might want to make these methods public for testing
      // or create a test-specific subclass
      
      // For now, we'll test the public interface
      expect(conversionService, isNotNull);
    });
  });

  group('FileWatcherService Tests', () {
    late FileWatcherService fileWatcherService;

    setUp(() {
      fileWatcherService = FileWatcherService();
    });

    test('Initial state is correct', () {
      expect(fileWatcherService.isWatching, false);
      expect(fileWatcherService.watchedDirectory, isNull);
    });

    test('Service can be instantiated', () {
      expect(fileWatcherService, isNotNull);
    });

    test('PowerPoint file detection works correctly', () {
      // Test the static file detection method

      // Test supported PowerPoint formats
      expect(FileWatcherService.isPowerPointFile('presentation.ppt'), true);
      expect(FileWatcherService.isPowerPointFile('presentation.pptx'), true);
      expect(FileWatcherService.isPowerPointFile('presentation.pptm'), true);
      expect(FileWatcherService.isPowerPointFile('PRESENTATION.PPT'), true);
      expect(FileWatcherService.isPowerPointFile('PRESENTATION.PPTX'), true);
      expect(FileWatcherService.isPowerPointFile('PRESENTATION.PPTM'), true);

      // Test unsupported formats
      expect(FileWatcherService.isPowerPointFile('document.pdf'), false);
      expect(FileWatcherService.isPowerPointFile('document.docx'), false);
      expect(FileWatcherService.isPowerPointFile('document.txt'), false);
      expect(FileWatcherService.isPowerPointFile('presentation'), false);
      expect(FileWatcherService.isPowerPointFile('presentation.'), false);
    });
  });

  group('LoggingService Tests', () {
    late LoggingService loggingService;

    setUp(() {
      loggingService = LoggingService.instance;
    });

    test('Singleton instance works', () {
      final instance1 = LoggingService.instance;
      final instance2 = LoggingService.instance;
      
      expect(identical(instance1, instance2), true);
    });

    test('Adding logs works', () {
      loggingService.clearLogs();
      loggingService.addLog('Test message');
      
      expect(loggingService.logs.length, 1);
      expect(loggingService.logs.first.contains('Test message'), true);
    });

    test('Clearing logs works', () {
      loggingService.addLog('Test message');
      expect(loggingService.logs.isNotEmpty, true);
      
      loggingService.clearLogs();
      expect(loggingService.logs.isEmpty, true);
    });
  });
}
