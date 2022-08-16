# frozen_string_literal: true

# Service for dealing with event RSVPs
class RsvpService < ApplicationService
  attr_accessor :event

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

  def non_respondents
    raise ArgumentError, "Event attribute must be set" unless @event.present?

    @event.unit.members.status_active - @event.rsvps.collect(&:member)
  end

  # has a family completely declined an event?
  # this feels a little kludgy...is there a more elegant way?
  def member_family_declined?(event)
    self.event = event
    raise ArgumentError, "Event does not require RSVPs" unless event.requires_rsvp

    # are all active family members represented in the RSVPs?
    active_family_rsvp_ids = @event.rsvps.map(&:unit_membership_id) & active_family_members.map(&:id)
    return false unless active_family_rsvp_ids.count == active_family_members.count

    responses = family_rsvps.map(&:response)
    return false if responses.include? "accepted"

    true
  end

  def family_rsvps
    family_member_ids = family_members.map(&:id)
    @event.rsvps.where(unit_membership: family_member_ids)
  end

  def family_members
    @member.family(include_self: true)
  end

  def active_family_members
    family_members.select(&:status_active?)
  end

  private

  def events
    unit.events.future.published.rsvp_required
  end

  def unit
    @member.unit
  end
end
