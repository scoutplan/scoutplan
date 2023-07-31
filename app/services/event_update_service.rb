# frozen_string_literal: true

# service for updating an event
class EventUpdateService < EventService
  def initialize(event, current_member = nil, params = {})
    @current_member = current_member
    super(event, params)
  end

  def perform
    @event.event_locations.destroy_all
    @event.assign_attributes(@params)
    @event.save!
    notify_members
  end

  def notify_members
    return unless @event.notify_members.downcase == "true"

    message = Message.new(author: @current_member,
                          status: :queued,
                          audience: @event.notify_recipients,
                          title: "Event Update",
                          body: notify_body)
    message.save!
  end

  def notify_body
    res = "<div>"
    res += @event.notify_message
    res += "</div>"
    res
  end
end
