module Events
  require "stripe"

  class PaymentsController < UnitContextController
    before_action :set_event

    def create
      @payment = @event.payments.new(payment_params)
      @payment.received_by = current_member
      @payment.amount *= 100
      @payment.save!
    end

    def index
      authorize @event, :organize?
      @payments = @event.payments
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def new_stripe
      @current_family = current_member.family
      @payments = @event.payments.where(unit_membership_id: @current_family.map(&:id))
      @family_rsvps = @event.rsvps.where(unit_membership_id: @current_family.map(&:id))
      @item_amount = @event.cost_youth * 100
      @subtotal = @family_rsvps.accepted.count * @item_amount
      @transaction_fee = StripePaymentService.new(current_unit).member_transaction_fee(@subtotal)
      @total_cost = @subtotal + @transaction_fee
      @total_paid = @payments&.sum(:amount) || 0
      @amount_due = @total_cost - @total_paid
      @quantity = @amount_due / @item_amount
      @payment = Payment.new(event: @event, unit_membership: current_member, amount: @amount_due, received_by: nil, method: "stripe")

      create_checkout_session
      redirect_to @session.url, allow_other_host: true
    end

    def new
      member = current_unit.members.find(params[:member])
      @payment = @event.payments.build(unit_membership: member, method: :cash)
      @current_family = member.family
      @payments = @event.payments.where(unit_membership_id: @current_family.map(&:id))
      @family_rsvps = @event.rsvps.where(unit_membership_id: @current_family.map(&:id))
      @total_cost = (@family_rsvps.accepted.youth.count * @event.cost_youth) + (@family_rsvps.accepted.adult.count * @event.cost_adult)
      @total_paid = ((@payments&.sum(:amount) || 0) / 100)
      @amount_due = @total_cost - @total_paid
      @payment.amount = @amount_due * 100
      @payment.status = :paid
      authorize @payment
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    private

    def create_checkout_session
      Stripe.api_key = ENV.fetch("STRIPE_SECRET_KEY")

      session_params = {
        customer_email: current_user.email,
        line_items: line_items,
        mode: "payment",
        payment_intent_data: {
          transfer_data: { destination: current_unit.payment_account.account_id }
        },
        success_url: unit_event_url(current_unit, @event),
        cancel_url: unit_event_url(current_unit, @event),
        client_reference_id: @payment.id
      }

      @session = Stripe::Checkout::Session.create(session_params)
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

    def payment_params
      params.require(:payment).permit(:amount, :unit_membership_id, :method)
    end

    def set_event
      @event = Event.find(params[:event_id])
    end
  end
end
