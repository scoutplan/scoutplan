# frozen_string_literal: true

# service for cancelling events & notifying the appropriate people
class EventCancellationService < EventService
  def cancel
    return if @event.cancelled?

    @event.status = :cancelled
    @event.save

    return false unless @event.save!
    return if @event.draft? # no need to send notifications for a draft

    send_notifications
    true
  end

  private

  # send out email & text notifications based on audience selected in UI
  # these will be enqueued into Sidekiq and despooled separately
  def send_notifications
    note = @params[:note]
    audience.each do |member|
      EventNotifier.perform_async(@event.id, member.id, note)
    end
  end

  # who's getting notified?
  def audience
    case @params[:message_audience]
    when "acceptors"
      @event.rsvps.accepted.map(&:member)
    when "active_members"
      @event.unit.members.status_active
    when "all_members"
      @event.unit.members.status_active_and_registered
    else
      []
    end
  end
end
