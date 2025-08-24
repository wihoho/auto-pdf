import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/app_config.dart';
import 'services/file_watcher_service.dart';
import 'services/conversion_service.dart';
import 'services/logging_service.dart';
import 'services/auth_service.dart';
import 'services/profile_service.dart';
import 'services/subscription_service.dart';
import 'providers/app_state_provider.dart';
import 'screens/app_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );

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
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ProfileService()),
        ChangeNotifierProvider(create: (_) => SubscriptionService()),
        Provider(create: (_) => FileWatcherService()),
        Provider(create: (_) => ConversionService()),
        Provider(create: (_) => LoggingService.instance),
      ],
      child: MaterialApp(
        title: AppConfig.appName,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const AppWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
