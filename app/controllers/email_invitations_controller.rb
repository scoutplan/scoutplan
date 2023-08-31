# frozen_string_literal: true

class EmailInvitationsController < UnitContextController
  def create
    @event = @unit.events.find(params[:event_id])
    EventInvitationMailer.with(event_id: @event.id, member: @current_member).event_invitation_email.deliver_later
  end
end
