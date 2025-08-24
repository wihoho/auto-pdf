import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logging/logging.dart';

import 'services/file_watcher_service.dart';
import 'services/conversion_service.dart';
import 'services/logging_service.dart';
import 'providers/app_state_provider.dart';
import 'screens/main_screen_simple.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize logging
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    LoggingService.instance.addLog(
      '${record.level.name}: ${record.time}: ${record.message}',
    );
  });

  runApp(const AutoPdfConverterApp());
}



class AutoPdfConverterApp extends StatelessWidget {
  const AutoPdfConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
        Provider(create: (_) => FileWatcherService()),
        Provider(create: (_) => ConversionService()),
        Provider(create: (_) => LoggingService.instance),
      ],
      child: MaterialApp(
        title: 'Auto PDF Converter',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const MainScreenSimple(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
