# frozen_string_literal: true

class EventInvitationMailerPreview < ActionMailer::Preview
  def event_invitation_email
    unit = Unit.first
    member = unit.members.first
    event = unit.events.future.first

    EventInvitationMailer.with(event_id: event.id, member: member).event_invitation_email
  end
end