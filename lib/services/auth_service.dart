import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logging/logging.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final _logger = Logger('AuthService');
  final _supabase = Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;
  bool get isAuthenticated => currentUser != null;
  Session? get currentSession => _supabase.auth.currentSession;

  /// Initialize auth service and listen to auth state changes
  void initialize() {
    _supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final session = data.session;
      
      _logger.info('Auth state changed: $event');
      
      switch (event) {
        case AuthChangeEvent.signedIn:
          _logger.info('User signed in: ${session?.user.email}');
          break;
        case AuthChangeEvent.signedOut:
          _logger.info('User signed out');
          break;
        case AuthChangeEvent.tokenRefreshed:
          _logger.fine('Token refreshed');
          break;
        default:
          break;
      }
      
      notifyListeners();
    });
  }

  /// Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      _logger.info('Attempting to sign up user: $email');
      
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: fullName != null ? {'full_name': fullName} : null,
      );
      
      if (response.user != null) {
        _logger.info('User signed up successfully: $email');
      }
      
      return response;
    } catch (e) {
      _logger.severe('Sign up error: $e');
      rethrow;
    }
  }

  /// Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _logger.info('Attempting to sign in user: $email');
      
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        _logger.info('User signed in successfully: $email');
      }
      
      return response;
    } catch (e) {
      _logger.severe('Sign in error: $e');
      rethrow;
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      _logger.info('Signing out user');
      await _supabase.auth.signOut();
      _logger.info('User signed out successfully');
    } catch (e) {
      _logger.severe('Sign out error: $e');
      rethrow;
    }
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    try {
      _logger.info('Sending password reset email to: $email');
      await _supabase.auth.resetPasswordForEmail(email);
      _logger.info('Password reset email sent successfully');
    } catch (e) {
      _logger.severe('Password reset error: $e');
      rethrow;
    }
  }

  /// Update user password
  Future<UserResponse> updatePassword(String newPassword) async {
    try {
      _logger.info('Updating user password');
      final response = await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      _logger.info('Password updated successfully');
      return response;
    } catch (e) {
      _logger.severe('Password update error: $e');
      rethrow;
    }
  }

  /// Update user profile
  Future<UserResponse> updateProfile({
    String? fullName,
    Map<String, dynamic>? data,
  }) async {
    try {
      _logger.info('Updating user profile');
      
      final updateData = <String, dynamic>{};
      if (fullName != null) updateData['full_name'] = fullName;
      if (data != null) updateData.addAll(data);
      
      final response = await _supabase.auth.updateUser(
        UserAttributes(data: updateData),
      );
      
      _logger.info('Profile updated successfully');
      return response;
    } catch (e) {
      _logger.severe('Profile update error: $e');
      rethrow;
    }
  }

  /// Get user display name
  String get userDisplayName {
    final user = currentUser;
    if (user == null) return 'Guest';
    
    final fullName = user.userMetadata?['full_name'] as String?;
    if (fullName != null && fullName.isNotEmpty) {
      return fullName;
    }
    
    return user.email ?? 'User';
  }

  /// Check if user email is verified
  bool get isEmailVerified {
    return currentUser?.emailConfirmedAt != null;
  }

  /// Resend email confirmation
  Future<void> resendEmailConfirmation() async {
    try {
      final email = currentUser?.email;
      if (email == null) throw Exception('No user email found');
      
      _logger.info('Resending email confirmation to: $email');
      await _supabase.auth.resend(
        type: OtpType.signup,
        email: email,
      );
      _logger.info('Email confirmation sent successfully');
    } catch (e) {
      _logger.severe('Resend email confirmation error: $e');
      rethrow;
    }
  }
}
