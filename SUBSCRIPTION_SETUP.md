# Subscription Setup Guide

This guide will help you set up the complete subscription workflow with Supabase Auth and Stripe integration for the Auto PDF Converter application.

## Prerequisites

- Supabase account and project
- Stripe account
- Supabase CLI installed
- Flutter development environment

## Part 1: Stripe Configuration

### 1. Create Products and Prices

1. Go to the [Stripe Dashboard](https://dashboard.stripe.com/)
2. Navigate to "Products" in the sidebar
3. Create two products:
   - **Premium Monthly**: Create a recurring price (e.g., $9.99/month)
   - **Premium Yearly**: Create a recurring price (e.g., $99.99/year)
4. Note down the **Price IDs** (they start with `price_`) - you'll need these later

### 2. Get API Keys

1. Go to "Developers" → "API keys" in the Stripe Dashboard
2. Copy your **Publishable key** and **Secret key**
3. **Important**: Keep the Secret key secure - it will be stored in Supabase

### 3. Configure Webhook

1. Go to "Developers" → "Webhooks"
2. Click "Add endpoint"
3. Set the endpoint URL to: `https://YOUR_SUPABASE_PROJECT_REF.supabase.co/functions/v1/stripe-webhook`
4. Select these events to listen for:
   - `checkout.session.completed`
   - `customer.subscription.updated`
   - `customer.subscription.deleted`
   - `invoice.payment_failed`
5. Copy the **Webhook signing secret** (starts with `whsec_`)

## Part 2: Supabase Backend Configuration

### 1. Update Configuration

1. Open `lib/config/app_config.dart`
2. Replace the placeholder values:
   ```dart
   static const String supabaseUrl = 'https://YOUR_PROJECT_REF.supabase.co';
   static const String supabaseAnonKey = 'YOUR_ANON_KEY';
   static const String stripePublishableKey = 'pk_test_...'; // Your Stripe publishable key
   static const String monthlyPriceId = 'price_...'; // Your monthly price ID
   static const String yearlyPriceId = 'price_...'; // Your yearly price ID
   ```

### 2. Set up Database

1. Run the migration to create the profiles table:
   ```bash
   supabase db push
   ```

   Or manually run the SQL from `supabase/migrations/001_create_profiles_table.sql` in your Supabase SQL editor.

### 3. Deploy Edge Functions

1. Deploy all Edge Functions:
   ```bash
   supabase functions deploy create-customer
   supabase functions deploy create-checkout-session
   supabase functions deploy create-portal-session
   supabase functions deploy stripe-webhook
   ```

### 4. Set Environment Secrets

1. Set your Stripe secrets in Supabase:
   ```bash
   supabase secrets set STRIPE_SECRET_KEY=sk_test_...
   supabase secrets set STRIPE_WEBHOOK_SIGNING_SECRET=whsec_...
   ```

### 5. Configure Stripe Webhook URL

1. Go back to your Stripe webhook configuration
2. Update the endpoint URL to your deployed function:
   `https://YOUR_SUPABASE_PROJECT_REF.supabase.co/functions/v1/stripe-webhook`

## Part 3: Flutter App Configuration

### 1. Install Dependencies

Run the following command to install the new dependencies:
```bash
flutter pub get
```

### 2. Test the Application

1. Run the app:
   ```bash
   flutter run
   ```

2. Test the authentication flow:
   - Sign up with a new account
   - Verify email (check your inbox)
   - Sign in

3. Test the subscription flow:
   - Click on "Upgrade to Premium" 
   - Complete the checkout process
   - Verify that the subscription status updates in real-time

## Part 4: Testing

### 1. Test Mode

- Use Stripe test cards for testing: `4242 4242 4242 4242`
- Test webhooks using Stripe CLI: `stripe listen --forward-to localhost:54321/functions/v1/stripe-webhook`

### 2. Verify Integration

1. **Authentication**: Users can sign up, sign in, and sign out
2. **Profile Creation**: New users automatically get a profile with Stripe customer ID
3. **Subscription Flow**: Users can subscribe and the status updates in real-time
4. **Feature Gating**: Free users see upgrade prompts when limits are reached
5. **Customer Portal**: Premium users can manage their subscription

## Part 5: Production Deployment

### 1. Environment Variables

For production, update your configuration:
- Use production Stripe keys
- Update webhook URLs to production endpoints
- Set proper return URLs for checkout success/cancel

### 2. Security Considerations

- Enable RLS (Row Level Security) on all tables
- Use environment variables for all secrets
- Implement proper error handling
- Add logging for debugging

## Troubleshooting

### Common Issues

1. **Webhook not receiving events**: Check the webhook URL and ensure the function is deployed
2. **Authentication errors**: Verify Supabase URL and anon key
3. **Stripe errors**: Check API keys and ensure they match the environment (test/live)
4. **Profile not created**: Check the database trigger and RLS policies

### Debugging

- Check Supabase function logs: `supabase functions logs stripe-webhook`
- Monitor Stripe webhook delivery in the dashboard
- Use Flutter debug console for client-side issues

## Next Steps

1. Customize the UI to match your brand
2. Add more subscription plans if needed
3. Implement usage tracking and limits
4. Add email notifications for subscription events
5. Set up analytics and monitoring

## Support

If you encounter issues:
1. Check the Supabase and Stripe documentation
2. Review the function logs for errors
3. Test with Stripe's test mode first
4. Ensure all environment variables are set correctly
