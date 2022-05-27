# frozen_string_literal: true

# business logic wrapper for event RSVPs
class EventRsvpService
  attr_accessor :target_member, :event

  def initialize(member)
    @member = member
  end

  def create_or_update(params)
    @event = Event.find(params[:event_id])
    @unit = @event.unit
    @target_member = @unit.memberships.find(params[:member_id])
    @rsvp = @event.rsvps.find_or_create_by(unit_membership: @target_member)
    @respondent = @member
    @rsvp.respondent = @respondent
    @rsvp.response = params[:response] if params[:response].present?
    @rsvp.paid = true if params[:payment] == "full"
    @rsvp.paid = false if params[:payment] == "none"
    @rsvp.includes_activity = true if params[:activity] == "yes"
    @rsvp.includes_activity = false if params[:activity] == "no"

    @rsvp.save!
    @event.reload

    EventNotifier.send_rsvp_confirmation(@rsvp)

    find_event_responses

    @rsvp
  end

  def non_respondents
    raise ArgumentError, "Event attribute must be set" unless @event.present?

    @event.unit.members.status_active - @event.rsvps.collect(&:member)
  end

  def accepted_responders
    @event.rsvps.accepted
  end

  def declined_responders
    @event.rsvps.declined
  end

  private

  def find_event_responses
    @non_respondents = @event.rsvp_tokens.collect(&:member) - @event.rsvps.collect(&:member)
    @non_invitees = @event.unit.members - @event.rsvp_tokens.collect(&:member) - @event.rsvps.collect(&:member)
  end
end