# frozen_string_literal: true

# Service for dealing with event RSVPs
class RsvpService < ApplicationService
  attr_accessor :member, :event

  def initialize(member, event = nil)
    @member = member
    @member = event.unit.members.find_by(user: member) if member.is_a?(User) && event.present?
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
    # family = @member.family
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

  def family_members
    @member.family(include_self: :prepend)
  end

  # for the current Event, return an array of members who haven't responded
  def non_respondents
    raise ArgumentError, "Event attribute must be set" unless @event.present?

    @event.unit.members.status_active - @event.rsvps.collect(&:member)
  end

  # for the current Member and Event, have we received responses from all active family members?
  def family_fully_responded?
    active_family_rsvp_ids = event.rsvps.map(&:unit_membership_id) & active_family_members.map(&:id) # intersection
    active_family_rsvp_ids.count == active_family_members.count
  end

  # has a family completely declined an event?
  # this feels a little kludgy...is there a more elegant way?
  def family_fully_declined?
    # self.event = event
    raise ArgumentError, "Event does not require RSVPs" unless event.requires_rsvp

    return false unless family_fully_responded?

    responses = family_rsvps.map(&:response)
    return false if responses.include? "accepted"

    true
  end

  def family_responses_in_words
    family_accepted = family_rsvps.select(&:accepted?)
    family_declined = family_rsvps.select(&:declined?)
    return "No responses yet." unless family_accepted.any? || family_declined.any?

    going = "#{list_of_words(family_accepted.map { |r| r.display_first_name(@member) }, linking_verb: true)} going" if family_accepted.any?
    not_going = "#{list_of_words(family_declined.map { |r| r.display_first_name(@member) }, linking_verb: true)} not#{family_accepted.present? ? '' : ' going'}" if family_declined.any?

    [going, not_going].compact.join("; ").sentence_case + ". "
  end

  def family_non_respondents
    return unless @event.present?

    active_family_members - @event.rsvps.map(&:unit_membership)
  end

  def family_rsvps
    return @family_rsvps if @family_rsvps.present?

    family_member_ids = family_members.map(&:id)
    @family_rsvps = @event.rsvps.where(unit_membership: family_member_ids)
  end

  # for the current member, return the next
  # event that isn't fully responded by the family
  def next_pending_event
    unit = member.unit
    candidate_events = unit.events.published.rsvp_required.where("starts_at BETWEEN ? AND ?",
                                                                 DateTime.now,
                                                                 30.days.from_now)
    candidate_events.each do |candidate_event|
      self.event = candidate_event
      return candidate_event unless family_fully_responded?
    end
    nil
  end

  # record a response to @event for the @member's active family
  def record_family_response(response)
    members = member.family(include_self: true)
    members.each do |family_member|
      next unless family_member.status_active?

      record_response(family_member, response)
    end
    MemberNotifier.new(member).send_family_rsvp_confirmation(event)
  end

  # record a response to @event for a given member
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

  def list_of_words(words, linking_verb: false)
    return "" unless words

    case words.count
    when 0
      ""
    when 1
      if linking_verb
        "#{words.first}#{words.first.downcase == 'you' ? ' are' : ' is'}"
      else
        words.first
      end
    when 2
      "#{words.first} and #{words.last}#{linking_verb ? ' are' : ''}"
    else
      "#{words[0..-2].join(', ')}, and #{words.last}#{linking_verb ? ' are' : ''}"
    end
  end

  def unit
    @member.unit
  end
end
