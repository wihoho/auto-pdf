import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logging/logging.dart';
import '../models/user_profile.dart';

class ProfileService extends ChangeNotifier {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  final _logger = Logger('ProfileService');
  final _supabase = Supabase.instance.client;

  UserProfile? _currentProfile;
  UserProfile? get currentProfile => _currentProfile;

  bool get hasActiveSubscription {
    return _currentProfile?.subscriptionStatus == 'active' &&
           _currentProfile?.subscriptionExpiresAt != null &&
           _currentProfile!.subscriptionExpiresAt!.isAfter(DateTime.now());
  }

  bool get isSubscriptionExpired {
    return _currentProfile?.subscriptionExpiresAt != null &&
           _currentProfile!.subscriptionExpiresAt!.isBefore(DateTime.now());
  }

  String? get stripeCustomerId => _currentProfile?.stripeCustomerId;

  /// Initialize profile service and start listening to profile changes
  void initialize() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId != null) {
      _startListeningToProfile(userId);
    }

    // Listen to auth state changes
    _supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final session = data.session;

      if (event == AuthChangeEvent.signedIn && session?.user != null) {
        _startListeningToProfile(session!.user.id);
      } else if (event == AuthChangeEvent.signedOut) {
        _currentProfile = null;
        notifyListeners();
      }
    });
  }

  /// Start listening to real-time profile changes
  void _startListeningToProfile(String userId) {
    _logger.info('Starting to listen to profile changes for user: $userId');

    // First, fetch the current profile
    _fetchProfile(userId);

    // Then listen to real-time changes
    _supabase
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('id', userId)
        .listen((data) {
          if (data.isNotEmpty) {
            _currentProfile = UserProfile.fromJson(data.first);
            _logger.info('Profile updated from real-time stream');
            notifyListeners();
          }
        });
  }

  /// Fetch user profile from database
  Future<void> _fetchProfile(String userId) async {
    try {
      _logger.info('Fetching profile for user: $userId');

      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response != null) {
        _currentProfile = UserProfile.fromJson(response);
        _logger.info('Profile fetched successfully');
      } else {
        _logger.info('No profile found, creating new profile');
        await _createProfile(userId);
      }

      notifyListeners();
    } catch (e) {
      _logger.severe('Error fetching profile: $e');
    }
  }

  /// Create a new user profile
  Future<void> _createProfile(String userId) async {
    try {
      _logger.info('Creating new profile for user: $userId');

      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('No authenticated user found');

      // Create Stripe customer first
      final stripeCustomerId = await _createStripeCustomer(user.email!);

      final profileData = {
        'id': userId,
        'updated_at': DateTime.now().toIso8601String(),
        'stripe_customer_id': stripeCustomerId,
        'subscription_status': null,
        'subscription_expires_at': null,
      };

      await _supabase.from('profiles').insert(profileData);

      _currentProfile = UserProfile.fromJson(profileData);
      _logger.info('Profile created successfully');
      notifyListeners();
    } catch (e) {
      _logger.severe('Error creating profile: $e');
      rethrow;
    }
  }

  /// Create Stripe customer via Supabase Edge Function
  Future<String> _createStripeCustomer(String email) async {
    try {
      _logger.info('Creating Stripe customer for: $email');

      final response = await _supabase.functions.invoke(
        'create-customer',
        body: {'email': email},
      );

      if (response.data != null && response.data['customer_id'] != null) {
        final customerId = response.data['customer_id'] as String;
        _logger.info('Stripe customer created: $customerId');
        return customerId;
      } else {
        throw Exception('Failed to create Stripe customer');
      }
    } catch (e) {
      _logger.severe('Error creating Stripe customer: $e');
      rethrow;
    }
  }

  /// Update profile data
  Future<void> updateProfile(Map<String, dynamic> updates) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('No authenticated user');

      _logger.info('Updating profile for user: $userId');

      updates['updated_at'] = DateTime.now().toIso8601String();

      await _supabase
          .from('profiles')
          .update(updates)
          .eq('id', userId);

      _logger.info('Profile updated successfully');
    } catch (e) {
      _logger.severe('Error updating profile: $e');
      rethrow;
    }
  }

  /// Get subscription status display text
  String get subscriptionStatusText {
    if (!hasActiveSubscription) return 'Free';
    
    final expiresAt = _currentProfile?.subscriptionExpiresAt;
    if (expiresAt != null) {
      final daysLeft = expiresAt.difference(DateTime.now()).inDays;
      if (daysLeft <= 7) {
        return 'Premium (expires in $daysLeft days)';
      }
    }
    
    return 'Premium';
  }

  /// Check if user can perform conversion (based on subscription or limits)
  bool canPerformConversion() {
    // If user has active subscription, allow unlimited conversions
    if (hasActiveSubscription) return true;

    // For free users, implement daily/monthly limits here
    // This would require tracking conversion counts in the profile
    // For now, we'll allow free conversions but this should be implemented
    return true;
  }

  /// Get remaining free conversions
  int getRemainingFreeConversions() {
    if (hasActiveSubscription) return -1; // Unlimited

    // This should be implemented based on your business logic
    // You'd track daily/monthly conversion counts in the profile
    return 5; // Placeholder
  }
}
