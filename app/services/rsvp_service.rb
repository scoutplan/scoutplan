# frozen_string_literal: true

# Service for dealing with event RSVPs
class RsvpService < ApplicationService
  def initialize(member)
    @member = member
    super()
  end

  # given a UnitMembership, return a list of
  # events without RSVPs for the member's family
  def unresponded_events
    return @unresponded_events if @unresponded_events.present?

    res = []
    family = @member.family
    family_member_ids = family.map(&:id)
    events.each do |event|
      rsvps = event.rsvps.where("unit_membership_id IN (?)", family_member_ids)
      res << event unless rsvps.count.positive?
    end
    @unresponded_events = res
  end

  private

  def events
    unit.events.future.published.rsvp_required
  end

  def unit
    @member.unit
  end
end
