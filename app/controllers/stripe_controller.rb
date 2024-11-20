# frozen_string_literal: true

# controller for handling Stripe payment callbacks
class StripeController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :verify_authenticity_token
  layout false

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def create
    Stripe.api_key = ENV.fetch("STRIPE_SECRET_KEY")
    @stripe_event = nil

    begin
      sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
      payload = request.body.read
      @stripe_event = Stripe::Webhook.construct_event(payload, sig_header, ENV.fetch("STRIPE_WEBHOOK_SIGNING_SECRET"))
    rescue JSON::ParserError
      # Invalid payload
      status 400
      return
    rescue Stripe::SignatureVerificationError
      # Invalid signature
      puts "⚠️  Signature verification failed."
      status 400
      return
    end

    fulfill_order if @stripe_event["type"] == "checkout.session.completed"

    render status: 200, json: { message: "success" }
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize

  private

  # fulfill the purchase...
  def fulfill_order
    object_data = @stripe_event["data"]["object"]

    amount        = object_data["amount_total"]
    payment_id    = object_data["client_reference_id"]
    stripe_id     = object_data["id"]
    stripe_status = object_data["payment_status"]

    payment = Payment.find(payment_id)
    payment.update(amount: amount, stripe_id: stripe_id, stripe_status: stripe_status, status: "paid")
  end
end

# "id": "evt_1MqeelIoZhk6Wdzog6zyk0nF",
# scoutplan-app-1          |   "object": "event",
# scoutplan-app-1          |   "api_version": "2022-11-15",
# scoutplan-app-1          |   "created": 1680018115,
# scoutplan-app-1          |   "data": {"object":{"id":"cs_test_a1m2kW8vxQdg6lKX78FcpSvMPEJXJ2oyWBcyUQL4ooScGqv1wJ98Oi4GOT","object":"checkout.session","after_expiration":null,"allow_promotion_codes":null,"amount_subtotal":2000,"amount_total":2000,"automatic_tax":{"enabled":false,"status":null},"billing_address_collection":null,"cancel_url":"https://local.scoutplan.org/u/1/schedule/3886","client_reference_id":null,"consent":null,"consent_collection":null,"created":1680017502,"currency":"usd","custom_fields":[],"custom_text":{"shipping_address":null,"submit":null},"customer":null,"customer_creation":"if_required","customer_details":{"address":{"city":null,"country":"US","line1":null,"line2":null,"postal_code":"94598","state":null},"email":"admin@scoutplan.org","name":"Calvin Broadus","phone":null,"tax_exempt":"none","tax_ids":[]},"customer_email":"admin@scoutplan.org","expires_at":1680103902,"invoice":null,"invoice_creation":{"enabled":false,"invoice_data":{"account_tax_ids":null,"custom_fields":null,"description":null,"footer":null,"metadata":{},"rendering_options":null}},"livemode":false,"locale":null,"metadata":{},"mode":"payment","payment_intent":"pi_3MqeejIoZhk6Wdzo06BFTxpc","payment_link":null,"payment_method_collection":"always","payment_method_options":{},"payment_method_types":["card","link","cashapp"],"payment_status":"paid","phone_number_collection":{"enabled":false},"recovered_from":null,"setup_intent":null,"shipping_address_collection":null,"shipping_cost":null,"shipping_details":null,"shipping_options":[],"status":"complete","submit_type":null,"subscription":null,"success_url":"https://local.scoutplan.org/u/1/schedule/3886","total_details":{"amount_discount":0,"amount_shipping":0,"amount_tax":0},"url":null}},
# scoutplan-app-1          |   "livemode": false,
# scoutplan-app-1          |   "pending_webhooks": 1,
# scoutplan-app-1          |   "request": {"id":null,"idempotency_key":null},
# scoutplan-app-1          |   "type": "checkout.session.completed"
# scoutplan-app-1          | }
