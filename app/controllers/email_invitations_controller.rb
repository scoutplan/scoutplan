# frozen_string_literal: true

class EmailInvitationsController < UnitContextController
  before_action :find_event

  def create
    @event.invite!(@current_member)
  end

  private

  def find_event
    @event = @unit.events.find(params[:event_id])
  end
end
