import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';

enum MonitoringStatus {
  idle,
  monitoring,
  error,
}

enum AuthStatus {
  unknown,
  authenticated,
  unauthenticated,
}

class AppStateProvider extends ChangeNotifier {
  // Existing file monitoring state
  String? _selectedFolderPath;
  MonitoringStatus _status = MonitoringStatus.idle;
  List<String> _logs = [];
  int _convertedFilesCount = 0;
  String? _lastError;

  // Authentication and subscription state
  AuthStatus _authStatus = AuthStatus.unknown;
  UserProfile? _userProfile;
  bool _isLoading = false;
  String? _authError;

  // Existing getters
  String? get selectedFolderPath => _selectedFolderPath;
  MonitoringStatus get status => _status;
  List<String> get logs => List.unmodifiable(_logs);
  int get convertedFilesCount => _convertedFilesCount;
  String? get lastError => _lastError;

  bool get isMonitoring => _status == MonitoringStatus.monitoring;
  bool get hasSelectedFolder => _selectedFolderPath != null;

  // New authentication and subscription getters
  AuthStatus get authStatus => _authStatus;
  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get authError => _authError;

  bool get isAuthenticated => _authStatus == AuthStatus.authenticated;
  bool get hasActiveSubscription => _userProfile?.hasActiveSubscription ?? false;
  bool get isFreeTier => !hasActiveSubscription;
  String? get stripeCustomerId => _userProfile?.stripeCustomerId;

  // Existing setters
  void setSelectedFolder(String? path) {
    _selectedFolderPath = path;
    notifyListeners();
  }

  void setStatus(MonitoringStatus status) {
    _status = status;
    _lastError = null; // Clear error when status changes
    notifyListeners();
  }

  void setError(String error) {
    _lastError = error;
    _status = MonitoringStatus.error;
    addLog('ERROR: $error');
    notifyListeners();
  }

  // New authentication and subscription setters
  void setAuthStatus(AuthStatus status) {
    _authStatus = status;
    _authError = null; // Clear auth error when status changes
    notifyListeners();
  }

  void setUserProfile(UserProfile? profile) {
    _userProfile = profile;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setAuthError(String error) {
    _authError = error;
    addLog('AUTH ERROR: $error');
    notifyListeners();
  }

  void addLog(String message) {
    final timestamp = DateTime.now().toString().substring(0, 19);
    _logs.insert(0, '[$timestamp] $message');
    
    // Keep only the last 100 log entries
    if (_logs.length > 100) {
      _logs = _logs.take(100).toList();
    }
    
    notifyListeners();
  }

  void incrementConvertedFiles() {
    _convertedFilesCount++;
    notifyListeners();
  }

  void clearLogs() {
    _logs.clear();
    notifyListeners();
  }

  void reset() {
    _selectedFolderPath = null;
    _status = MonitoringStatus.idle;
    _logs.clear();
    _convertedFilesCount = 0;
    _lastError = null;
    notifyListeners();
  }

  void resetAuth() {
    _authStatus = AuthStatus.unauthenticated;
    _userProfile = null;
    _authError = null;
    _isLoading = false;
    notifyListeners();
  }

  void resetAll() {
    reset();
    resetAuth();
  }

  // Subscription-related helper methods
  bool canPerformConversion() {
    // If user has active subscription, allow unlimited conversions
    if (hasActiveSubscription) return true;

    // For free users, implement daily/monthly limits here
    // This would require tracking conversion counts in the profile
    // For now, we'll allow free conversions but this should be implemented
    return true;
  }

  int getRemainingFreeConversions() {
    if (hasActiveSubscription) return -1; // Unlimited

    // This should be implemented based on your business logic
    // You'd track daily/monthly conversion counts in the profile
    return 5; // Placeholder
  }

  String get subscriptionStatusText {
    if (!hasActiveSubscription) return 'Free';

    final expiresAt = _userProfile?.subscriptionExpiresAt;
    if (expiresAt != null) {
      final daysLeft = expiresAt.difference(DateTime.now()).inDays;
      if (daysLeft <= 7) {
        return 'Premium (expires in $daysLeft days)';
      }
    }

    return 'Premium';
  }
}
