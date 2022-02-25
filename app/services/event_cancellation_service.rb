# frozen_string_literal: true

# service for cancelling events & notifying the appropriate people
class EventCancellationService < BaseEventService
  def cancel
    return if @event.cancelled?

    @event.status = :cancelled
    return false unless @event.save
    return if @event.draft? # no need to send notifications for a draft

    send_notifications
    true
  end

  private

  # send out email & text notifications based on audience selected in UI
  def send_notifications
    set_audience
    return if @audience.empty?

    notifier = EventNotifier.new(@event)
    @audience.each do |member|
      notifier.send_cancellation(member)
    end
  end

  # who's getting notified?
  def set_audience
    case @params[:message_audience]
    when "none"
      @audience = []
    when "acceptors"
      @audience = @event.rsvps.accepted
    when "active_members"
      @audience = @event.unit.members.status_active
    when "all_members"
      @audience = @event.unit.members.status_active_and_registered
    end
  end
end
