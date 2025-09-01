import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import Stripe from "https://esm.sh/stripe@10.12.0?target=deno"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.31.0'

const stripe = new Stripe(Deno.env.get('STRIPE_SECRET_KEY') as string, {
  apiVersion: "2022-08-01",
  httpClient: Stripe.createFetchHttpClient(),
})

const cryptoProvider = Stripe.createSubtleCryptoProvider()

serve(async (req) => {
  const signature = req.headers.get("Stripe-Signature")
  const signingSecret = Deno.env.get('STRIPE_WEBHOOK_SIGNING_SECRET')!
  const body = await req.text()

  let receivedEvent
  try {
    receivedEvent = await stripe.webhooks.constructEventAsync(
      body, signature!, signingSecret, undefined, cryptoProvider
    )
  } catch (err) {
    console.error(`Webhook signature verification failed: ${err.message}`)
    return new Response(err.message, { status: 400 })
  }

  console.log(`Received event: ${receivedEvent.type}`)

  // Create Supabase admin client
  const supabaseAdmin = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  )

  try {
    switch (receivedEvent.type) {
      case 'checkout.session.completed': {
        const session = receivedEvent.data.object as Stripe.Checkout.Session
        const customerId = session.customer as string
        
        console.log(`Processing checkout session completed for customer: ${customerId}`)
        
        // Get subscription details
        const subscription = await stripe.subscriptions.retrieve(session.subscription as string)
        
        // Calculate expiration date
        const expiresAt = new Date(subscription.current_period_end * 1000)
        
        // Update user profile in Supabase
        const { error } = await supabaseAdmin
          .from('profiles')
          .update({
            subscription_status: 'active',
            subscription_expires_at: expiresAt.toISOString(),
            subscription_price_id: subscription.items.data[0].price.id,
            updated_at: new Date().toISOString()
          })
          .eq('stripe_customer_id', customerId)

        if (error) {
          console.error("Failed to update user profile:", error)
          throw error
        }
        
        console.log(`Successfully updated subscription for customer: ${customerId}`)
        break
      }

      case 'customer.subscription.updated': {
        const subscription = receivedEvent.data.object as Stripe.Subscription
        const customerId = subscription.customer as string
        
        console.log(`Processing subscription update for customer: ${customerId}`)
        
        const expiresAt = new Date(subscription.current_period_end * 1000)
        const status = subscription.status === 'active' ? 'active' : 'inactive'
        
        const { error } = await supabaseAdmin
          .from('profiles')
          .update({
            subscription_status: status,
            subscription_expires_at: expiresAt.toISOString(),
            subscription_price_id: subscription.items.data[0].price.id,
            updated_at: new Date().toISOString()
          })
          .eq('stripe_customer_id', customerId)

        if (error) {
          console.error("Failed to update subscription:", error)
          throw error
        }
        
        console.log(`Successfully updated subscription status to ${status} for customer: ${customerId}`)
        break
      }

      case 'customer.subscription.deleted': {
        const subscription = receivedEvent.data.object as Stripe.Subscription
        const customerId = subscription.customer as string
        
        console.log(`Processing subscription cancellation for customer: ${customerId}`)
        
        const { error } = await supabaseAdmin
          .from('profiles')
          .update({
            subscription_status: 'cancelled',
            subscription_expires_at: new Date(subscription.current_period_end * 1000).toISOString(),
            updated_at: new Date().toISOString()
          })
          .eq('stripe_customer_id', customerId)

        if (error) {
          console.error("Failed to update cancelled subscription:", error)
          throw error
        }
        
        console.log(`Successfully cancelled subscription for customer: ${customerId}`)
        break
      }

      case 'invoice.payment_failed': {
        const invoice = receivedEvent.data.object as Stripe.Invoice
        const customerId = invoice.customer as string
        
        console.log(`Processing payment failure for customer: ${customerId}`)
        
        // You might want to send an email notification here
        // For now, we'll just log it
        console.log(`Payment failed for customer: ${customerId}`)
        break
      }

      default:
        console.log(`Unhandled event type: ${receivedEvent.type}`)
    }
  } catch (error) {
    console.error(`Error processing webhook: ${error}`)
    return new Response(`Webhook error: ${error.message}`, { status: 400 })
  }

  return new Response(JSON.stringify({ received: true }), { 
    status: 200,
    headers: { "Content-Type": "application/json" }
  })
})
