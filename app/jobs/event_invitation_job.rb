# frozen_string_literal: true

class EventInvitationJob < ApplicationJob
  queue_as :default

  def perform(member)
    @member = member
    @unit = @member.unit
    return unless @member.receives_event_invitations?

    process_events
    @member.enqueue_event_invitation_job!(:tomorrow)
  end

  private

  def events
    @unit.events.future.published.select { |event| event.should_invite?(@member) }
  end

  def process_events
    events.each do |event|
      event.invite!(@member)
    end
  end
end
