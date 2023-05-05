# frozen_string_literal: true

# This service is responsible for handling payments
class PaymentsService
  attr_accessor :member

  def initialize(event, member = nil)
    @event = event
    @member = member
  end

  def paid?
    return :in_full if family_amount_due.zero? || family_amount_due.negative?
    return :partial if family_amount_paid.positive?
    return :none if family_amount_paid.zero?

    :unknown
  end

  def family_ids
    @member.family.map(&:id)
  end

  def family_payments
    return unless @member

    @event.payments.where(unit_membership_id: family_ids)
  end

  def family_amount_paid
    family_payments.sum(&:amount_in_dollars)
  end

  def family_rsvps
    @event.rsvps.where(unit_membership_id: family_ids)
  end

  def family_amount_total
    @event.cost_adult * (family_rsvps&.accepted&.adult&.count || 0) + @event.cost_youth * (family_rsvps&.accepted&.youth&.count || 0)
  end

  def family_amount_due
    family_amount_total - family_amount_paid
  end
end
