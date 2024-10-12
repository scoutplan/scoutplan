module Events
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
    def new
      member = current_unit.unit_memberships.find(params[:member])
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

    def payment_params
      params.require(:payment).permit(:amount, :unit_membership_id, :method)
    end

    def set_event
      @event = Event.find(params[:event_id])
    end
  end
end
