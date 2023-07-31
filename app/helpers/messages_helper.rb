# frozen_string_literal: true

# helpers for displaying Messages
module MessagesHelper
  def recipients_to_s(message)
    if message.audience == "everyone"
      if message.member_status == "active_and_registered"
        result = "#{message.unit.name} members, guardians, friends, and family"
      else
        result = "#{message.unit.name} members and guardians"
      end
      result = "Adult " + result if message.member_type == "adults_only"

      return result
    end

    if message.audience =~ /event_(\d+)_attendees/
      event = Event.find($1)

      return "#{event.title} attendees and guardians" if message.member_type == "youth_and_adults"

      return "Adult #{event.title} attendees and guardians"
    end

    "Unknown"
  end
end
