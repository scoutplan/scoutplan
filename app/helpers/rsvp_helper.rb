# frozen_string_literal: true

# class for composing digests
module RsvpHelper
  # given a UnitMembership, return a list of
  # Events for which RSVPs are incomplete.
  def open_rsvps(member)
    family_members = member.family
    result = []
    events = member.unit.events.future.published.rsvp_required
    events.each do |event|
      result << event unless family_rsvps_complete(family_members, event)
    end
    result
  end

  # TODO: move this to RsvpService
  # given a list of family members and an event, determine whether the
  # family's RSVPs are complete
  def family_rsvps_complete(family_members, event)
    result = true

    family_members.each do |family_member|
      rsvp = event.rsvp_for(family_member)
      result &&= rsvp.present?
    end

    result
  end

  def unresponded_events(member)
    []
  end
end
