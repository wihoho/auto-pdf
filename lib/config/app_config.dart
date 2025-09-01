class AppConfig {
  // Supabase Configuration
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
  
  // Stripe Configuration
  static const String stripePublishableKey = 'YOUR_STRIPE_PUBLISHABLE_KEY';
  
  // Stripe Price IDs (from Stripe Dashboard)
  static const String monthlyPriceId = 'price_monthly_subscription_id';
  static const String yearlyPriceId = 'price_yearly_subscription_id';
  
  // App Configuration
  static const String appName = 'Auto PDF Converter';
  static const String appVersion = '1.0.0';
  
  // Feature flags
  static const bool enableSubscriptions = true;
  static const bool enableFreeTrialFeatures = true;
  
  // URLs
  static const String privacyPolicyUrl = 'https://your-website.com/privacy';
  static const String termsOfServiceUrl = 'https://your-website.com/terms';
  static const String supportUrl = 'https://your-website.com/support';
  
  // Subscription plans
  static const Map<String, dynamic> monthlyPlan = {
    'name': 'Premium Monthly',
    'price': '\$9.99',
    'priceId': monthlyPriceId,
    'interval': 'month',
    'features': [
      'Unlimited file conversions',
      'Batch processing',
      'Priority support',
      'Advanced monitoring',
    ],
  };
  
  static const Map<String, dynamic> yearlyPlan = {
    'name': 'Premium Yearly',
    'price': '\$99.99',
    'priceId': yearlyPriceId,
    'interval': 'year',
    'savings': 'Save 17%',
    'features': [
      'Unlimited file conversions',
      'Batch processing',
      'Priority support',
      'Advanced monitoring',
      'Early access to new features',
    ],
  };
  
  // Free tier limitations
  static const int freeConversionsPerDay = 5;
  static const int freeConversionsPerMonth = 50;
}
