module Events
  require "stripe"

  class OnlinePaymentsController < UnitContextController
    before_action :set_event

    # https://docs.stripe.com/connect/collect-then-transfer-guide?platform=web#create-a-checkout-session
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def new
      @current_family = current_member.family
      @payments = @event.payments.where(unit_membership_id: @current_family.map(&:id))
      @family_rsvps = @event.rsvps.where(unit_membership_id: @current_family.map(&:id))
      @subtotal = @family_rsvps.accepted.youth.count * @event.cost_youth * 100
      @subtotal += @family_rsvps.accepted.adult.count * @event.cost_adult * 100
      @transaction_fee = StripePaymentService.new(current_unit).member_transaction_fee(@subtotal)
      @total_cost = @subtotal + @transaction_fee
      @total_paid = @payments&.sum(:amount) || 0
      @amount_due = @total_cost - @total_paid
      @payment = Payment.create(event:           @event,
                                unit_membership: current_member,
                                amount:          @amount_due,
                                received_by:     nil,
                                method:          "stripe")

      create_checkout_session
      redirect_to @session.url, allow_other_host: true
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    private

    def set_event
      @event = current_unit.events.find(params[:event_id])
    end

    # rubocop:disable Metrics/AbcSize
    def line_items
      result = []

      result << if @event.cost_youth == @event.cost_adult
                  {
                    price_data: {
                      currency:     "usd",
                      unit_amount:  @event.cost_youth * 100,
                      product_data: { name: "#{@event.title}, per person" }
                    },
                    quantity:   @family_rsvps.accepted.count
                  }
                else
                  [
                    {
                      price_data: {
                        currency:     "usd",
                        unit_amount:  @event.cost_youth * 100,
                        product_data: { name: "#{@event.title}, per youth" }
                      },
                      quantity:   @family_rsvps.accepted.youth.count
                    }, {
                      price_data: {
                        currency:     "usd",
                        unit_amount:  @event.cost_adult * 100,
                        product_data: { name: "#{@event.title}, per adult" }
                      },
                      quantity:   @family_rsvps.accepted.adult.count
                    }
                  ]
                end

      result << {
        price_data: {
          currency:     "usd",
          unit_amount:  @transaction_fee,
          product_data: { name: "Transaction Fee" }
        },
        quantity:   1
      }

      result
    end
    # rubocop:enable Metrics/AbcSize

    def create_checkout_session
      Stripe.api_key = ENV.fetch("STRIPE_SECRET_KEY")

      session_params = {
        customer_email:      current_user.email,
        line_items:          line_items,
        mode:                "payment",
        payment_intent_data: {
          transfer_data: { destination: current_unit.payment_account.account_id }
        },
        success_url:         unit_event_url(current_unit, @event),
        cancel_url:          unit_event_url(current_unit, @event),
        client_reference_id: @payment.id
      }

      @session = Stripe::Checkout::Session.create(session_params)
    end
  end
end
