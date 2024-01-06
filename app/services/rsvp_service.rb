# frozen_string_literal: true

class RsvpService < ApplicationService
  attr_accessor :unit_membership, :event

  def initialize(user_or_unit_membership, event = nil)
    @unit_membership = user_or_unit_membership
    if user_or_unit_membership.is_a?(User) && event.present?
      @unit_membership = event.unit.unit_memberships.find_by(user: user_or_unit_membership)
    end
    @event = event
    super()
  end

  def active_family_members
    family_members.select(&:status_active?)
  end

  # return a list of events without RSVPs for the member's family
  def unresponded_events
    # return @unresponded_events if @unresponded_events.present?

    res = []
    # family = unit_membership.family
    # family_member_ids = family.map(&:id)
    events.each do |event|
      self.event = event
      # rsvps = event.rsvps.where("unit_membership_id IN (?)", family_member_ids)
      # res << event unless rsvps.count.positive?
      res << event unless family_fully_responded?
    end
    res
  end

  # for the given Event, are there any responses at all?
  def any_responses?
    family_rsvps.count.positive?
  end

  # a list of events where the RSVPs are closing in the next 24 hours
  # def expiring_rsvp_events
  #   result = unit.events.published.future.rsvp_required
  #   result.select { |e| e.rsvp_closes_at.tomorrow? }
  # end

  def family_members
    unit_membership.family(include_self: :prepend)
  end

  # for the current Event, return an array of members who haven't responded
  def non_respondents
    raise ArgumentError, "Event attribute must be set" unless event.present?

    event.unit.members.status_active - event.rsvps.collect(&:unit_membership)
  end

  def family_fully_responded?
    active_family_rsvp_ids = event.rsvps.map(&:unit_membership_id) & active_family_members.map(&:id) # intersection
    active_family_rsvp_ids.count == active_family_members.count
  end

  def family_fully_declined?
    return false unless event.requires_rsvp?
    return false unless family_fully_responded?

    responses = family_rsvps.map(&:response)
    return false if responses.include? "accepted"

    true
  end

  def family_responses_in_words
    clauses = []

    EventRsvp::RESPONSE_OPTIONS.each do |response, _intval|
      responses = family_rsvps.select { |r| r.response == response.to_s }
      next unless responses.count.positive?

      names = responses.map { |r| r.display_first_name(unit_membership) }
      clauses << response_clause(response, names)
    end

    clauses.join("; ").upcase_first
  end

  def response_clause(response, names)
    [names.to_grammatical_list, names.be_conjugation, I18n.t("global.event_rsvp_responses.#{response}")].join(" ")
  end

  def family_non_respondents
    return unless event.present?

    active_family_members - event.rsvps.map(&:unit_membership)
  end

  def family_rsvps
    return @family_rsvps if @family_rsvps.present?

    family_member_ids = family_members.map(&:id)
    @family_rsvps = event.rsvps.where(unit_membership: family_member_ids)
  end

  def family_accepted
    family_rsvps.select(&:accepted?)
  end

  # for the current member, return the next
  # event that isn't fully responded by the family
  def next_pending_event
    unit = unit_membership.unit
    candidate_events = unit.events.published.rsvp_required.where("starts_at BETWEEN ? AND ?",
                                                                 DateTime.now,
                                                                 30.days.from_now)
    candidate_events.each do |candidate_event|
      self.event = candidate_event
      return candidate_event unless family_fully_responded?
    end
    nil
  end

  # record a response to event for the unit_membership's active family
  def record_family_response(response)
    members = unit_membership.family(include_self: true)
    members.each do |family_member|
      next unless family_member.status_active?

      record_response(family_member, response)
    end
    MemberNotifier.new(unit_membership).send_family_rsvp_confirmation(event)
  end

  # record a response to event for a given member
  def record_response(member, response)
    rsvp = event.rsvps.create_with(respondent: member, response: response)
                .find_or_create_by!(event: event, unit_membership: member)
    rsvp.update(response: response)
  end

  private

  def events
    # debugger
    unit.events.future.published.rsvp_required
  end

  def unit
    unit_membership.unit
  end
end
