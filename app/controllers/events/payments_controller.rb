# frozen_string_literal: true

module Events
  require "stripe"

  class PaymentsController < UnitContextController
    before_action :set_event

    def index
      @current_family = @current_member.family
      @payments = @event.payments.where(unit_membership_id: @current_family.map(&:id))
    end

    def new
      @current_family = @current_member.family
      @payments = @event.payments.where(unit_membership_id: @current_family.map(&:id))
      @family_rsvps = @event.rsvps.where(unit_membership_id: @current_family.map(&:id))
      @item_amount = @event.cost_youth * 100
      @total_cost = @family_rsvps.accepted.count * @item_amount
      @total_paid = @payments&.sum(:amount) || 0
      @amount_due = @total_cost - @total_paid
      @quantity = @amount_due / @item_amount
      @payment = Payment.create(event: @event, unit_membership: @current_member)

      create_checkout_session
      redirect_to @session.url, allow_other_host: true
    end

    private

    def create_checkout_session
      Stripe.api_key = ENV.fetch("STRIPE_SECRET_KEY")
      @session = Stripe::Checkout::Session.create({
        customer_email: current_user.email,
        line_items: line_items,
        mode: "payment",
        payment_intent_data: {
          transfer_data: { destination: @unit.payment_account.account_id }
        },
        success_url: unit_event_url(@unit, @event),
        cancel_url: unit_event_url(@unit, @event),
        client_reference_id: @payment.id
      })
    end

    def line_items
      [{
        price_data: {
          currency: "usd",
          unit_amount: @item_amount,
          product_data: { name: @event.title }
        },
        quantity: @quantity
      }]
    end

    def set_event
      @event = Event.find(params[:event_id])
    end
  end
end
