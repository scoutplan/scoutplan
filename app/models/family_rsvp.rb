class FamilyRsvp
  attr_reader :unit_membership, :event

  def initialize(unit_membership, event)
    @unit_membership = unit_membership
    @event = event
  end

  ### Payment methods
  def balance_due
    cost - amount_paid
  end

  def cost
    subtotal = event_rsvps.sum(&:cost)
    fees = StripePaymentService.new(unit_membership.unit).member_transaction_fee(subtotal)
    subtotal + fees
  end

  def amount_paid
    payments.paid.sum(&:amount_in_dollars)
  end

  def paid?
    return :in_full unless balance_due.positive?
    return :partial if amount_paid.positive?

    :none
  end

  def payments
    event.payments.where(unit_membership_id: family_member_ids)
  end

  ### Family member methods
  def family_members
    @family_members ||= unit_membership&.family(include_self: :prepend)&.map do |member|
      FamilyMemberRsvp.new(member, event)
    end
  end

  def active_family_members
    @active_family_members ||= family_members.select(&:status_active?)
  end

  def active_family_member_ids
    @active_family_member_ids ||= active_family_members.map(&:id)
  end

  def family_member_ids
    @family_member_ids ||= family_members.map(&:id)
  end

  ### RSVP methods
  def event_rsvps
    @event_rsvps ||= event.rsvps.where(unit_membership: family_members)
  end

  def rsvps
    event_rsvps
  end

  def family_fully_responded?
    event_rsvps.map(&:unit_membership) & active_family_members == active_family_members
  end

  def any_accepted?
    responses = event_rsvps.map(&:response)
    return true if responses.include? "accepted"

    false
  end

  def family_fully_declined?
    return false unless event.requires_rsvp?
    return false unless family_fully_responded?

    responses = event_rsvps.map(&:response)
    return false if responses.include? "accepted"

    true
  end

  def family_responses_in_words
    clauses = []

    %w[accepted accepted_pending declined declined_pending].each do |response|
      rsvps = event_rsvps.select(&:response)
      next unless rsvps.count.positive?

      names = rsvps.map { |r| r.display_first_name(unit_membership) }
      clauses << response_clause(response, names)
    end

    clauses.join("; ").upcase_first
  end

  def response_clause(response, names)
    [
      names.to_grammatical_list,
      names.be_conjugation,
      I18n.t("global.event_rsvp_responses.#{response}")
    ].join(" ")
  end

  ### Response methods
  def responses
    event_rsvps.map(&:response).uniq
  end

  def acceptances?
    responses.include? "accepted"
  end

  def declines?
    responses.include? "declined"
  end

  ### Status methods

  def status
    return :completed if active_family_member_ids & event_rsvps&.map(&:unit_membership_id) == active_family_member_ids
    return :partial if event_rsvps.any?

    :none
  end

  def completed?
    status == :completed
  end

  def incomplete?
    !completed?
  end

  def partial?
    status == :partial
  end

  def none?
    status == :none
  end

  def new_record?
    status == :none
  end
end
