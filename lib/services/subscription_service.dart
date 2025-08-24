import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:logging/logging.dart';
import '../config/app_config.dart';

class SubscriptionService extends ChangeNotifier {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  final _logger = Logger('SubscriptionService');
  final _supabase = Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Create Stripe checkout session and redirect to payment
  Future<bool> createCheckoutSession({
    required String priceId,
    required String customerId,
  }) async {
    try {
      _setLoading(true);
      _logger.info('Creating checkout session for price: $priceId');

      final response = await _supabase.functions.invoke(
        'create-checkout-session',
        body: {
          'priceId': priceId,
          'customerId': customerId,
        },
      );

      if (response.data != null && response.data['url'] != null) {
        final checkoutUrl = response.data['url'] as String;
        _logger.info('Checkout session created, redirecting to: $checkoutUrl');
        
        return await _launchCheckoutUrl(checkoutUrl);
      } else {
        _logger.severe('Failed to create checkout session: ${response.data}');
        return false;
      }
    } catch (e) {
      _logger.severe('Error creating checkout session: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Launch checkout URL in default browser
  Future<bool> _launchCheckoutUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        return true;
      } else {
        _logger.severe('Could not launch checkout URL: $url');
        return false;
      }
    } catch (e) {
      _logger.severe('Error launching checkout URL: $e');
      return false;
    }
  }

  /// Subscribe to monthly plan
  Future<bool> subscribeMonthly(String customerId) async {
    return await createCheckoutSession(
      priceId: AppConfig.monthlyPriceId,
      customerId: customerId,
    );
  }

  /// Subscribe to yearly plan
  Future<bool> subscribeYearly(String customerId) async {
    return await createCheckoutSession(
      priceId: AppConfig.yearlyPriceId,
      customerId: customerId,
    );
  }

  /// Create customer portal session for subscription management
  Future<bool> openCustomerPortal(String customerId) async {
    try {
      _setLoading(true);
      _logger.info('Creating customer portal session for: $customerId');

      final response = await _supabase.functions.invoke(
        'create-portal-session',
        body: {
          'customerId': customerId,
        },
      );

      if (response.data != null && response.data['url'] != null) {
        final portalUrl = response.data['url'] as String;
        _logger.info('Customer portal session created, redirecting to: $portalUrl');
        
        return await _launchCheckoutUrl(portalUrl);
      } else {
        _logger.severe('Failed to create customer portal session: ${response.data}');
        return false;
      }
    } catch (e) {
      _logger.severe('Error creating customer portal session: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Cancel subscription
  Future<bool> cancelSubscription(String customerId) async {
    try {
      _setLoading(true);
      _logger.info('Canceling subscription for customer: $customerId');

      final response = await _supabase.functions.invoke(
        'cancel-subscription',
        body: {
          'customerId': customerId,
        },
      );

      if (response.data != null && response.data['success'] == true) {
        _logger.info('Subscription canceled successfully');
        return true;
      } else {
        _logger.severe('Failed to cancel subscription: ${response.data}');
        return false;
      }
    } catch (e) {
      _logger.severe('Error canceling subscription: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Get subscription details
  Future<Map<String, dynamic>?> getSubscriptionDetails(String customerId) async {
    try {
      _logger.info('Fetching subscription details for customer: $customerId');

      final response = await _supabase.functions.invoke(
        'get-subscription',
        body: {
          'customerId': customerId,
        },
      );

      if (response.data != null) {
        _logger.info('Subscription details fetched successfully');
        return response.data as Map<String, dynamic>;
      } else {
        _logger.warning('No subscription details found');
        return null;
      }
    } catch (e) {
      _logger.severe('Error fetching subscription details: $e');
      return null;
    }
  }

  /// Check if price ID is for monthly plan
  bool isMonthlyPlan(String priceId) {
    return priceId == AppConfig.monthlyPriceId;
  }

  /// Check if price ID is for yearly plan
  bool isYearlyPlan(String priceId) {
    return priceId == AppConfig.yearlyPriceId;
  }

  /// Get plan name from price ID
  String getPlanName(String priceId) {
    if (isMonthlyPlan(priceId)) {
      return AppConfig.monthlyPlan['name'] as String;
    } else if (isYearlyPlan(priceId)) {
      return AppConfig.yearlyPlan['name'] as String;
    }
    return 'Unknown Plan';
  }

  /// Get plan price from price ID
  String getPlanPrice(String priceId) {
    if (isMonthlyPlan(priceId)) {
      return AppConfig.monthlyPlan['price'] as String;
    } else if (isYearlyPlan(priceId)) {
      return AppConfig.yearlyPlan['price'] as String;
    }
    return 'Unknown Price';
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
