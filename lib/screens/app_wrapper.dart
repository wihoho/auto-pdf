import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../providers/app_state_provider.dart';
import 'auth/auth_screen.dart';
import 'main_screen_simple.dart';

class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  void _initializeServices() {
    final authService = Provider.of<AuthService>(context, listen: false);
    final profileService = Provider.of<ProfileService>(context, listen: false);
    final appState = Provider.of<AppStateProvider>(context, listen: false);

    // Initialize services
    authService.initialize();
    profileService.initialize();

    // Listen to auth state changes and update app state
    authService.addListener(() {
      if (authService.isAuthenticated) {
        appState.setAuthStatus(AuthStatus.authenticated);
      } else {
        appState.setAuthStatus(AuthStatus.unauthenticated);
      }
    });

    // Listen to profile changes and update app state
    profileService.addListener(() {
      appState.setUserProfile(profileService.currentProfile);
    });

    // Set initial auth status
    if (authService.isAuthenticated) {
      appState.setAuthStatus(AuthStatus.authenticated);
    } else {
      appState.setAuthStatus(AuthStatus.unauthenticated);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        // Show loading screen while determining auth state
        if (appState.authStatus == AuthStatus.unknown) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Show auth screen if not authenticated
        if (appState.authStatus == AuthStatus.unauthenticated) {
          return const AuthScreen();
        }

        // Show main app if authenticated
        return const MainScreenSimple();
      },
    );
  }
}
