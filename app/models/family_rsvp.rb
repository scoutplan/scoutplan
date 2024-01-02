class FamilyRsvp
  attr_reader :unit_membership, :event

  def initialize(unit_membership, event)
    @unit_membership = unit_membership
    @event = event
  end

  def family_members
    @family_members ||= unit_membership.family(include_self: :prepend)
  end

  def active_family_members
    family_members.select(&:status_active?)
  end

  def active_family_member_ids
    @active_family_member_ids ||= active_family_members.map(&:id)
  end

  def family_member_ids
    @family_member_ids ||= family_members.map(&:id)
  end

  def event_rsvps
    @event_rsvps ||= event.rsvps.where(unit_membership_id: family_member_ids)
  end

  def family_fully_responded?
    @event_rsvps.map(&:unit_membership_id) & active_family_member_ids == active_family_member_ids
  end

  def accepted?
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
end
