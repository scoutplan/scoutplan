# frozen_string_literal: true

# helpers for displaying Messages
module MessagesHelper
  def recipients_to_s(message)
    result = member_cohort_to_s(message) if message.member_cohort?
    result = event_cohort_to_s(message) if message.event_cohort?
    result
  end

  def member_cohort_to_s(message)
    case message.recipients
    when "all_members"
      "Active + Family & Friends"
    when "active_members"
      "Active Members"
    else
      "Unknown"
    end
  end

  # Returns a string description of an event cohort
  # Example: message.recipients = "event_1234_cohort"
  # Event.find(1234) => { title: "March Camping Trip" }
  # event_cohort_to_s(message) => "March Camping Trip Attendees"
  def event_cohort_to_s(message)
    recipient_parts = message.recipients.split("_")
    event_id = recipient_parts.second
    event = Event.find(event_id)
    "#{event.title} Attendees"
  end
end
