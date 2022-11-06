# frozen_string_literal: true

# A class to notify members about various events. A Notifier
# wraps both email and text (and any other future communication modes).
#
# The Notifier is responsible for honoring Unit, Member, and User communication
# preferences and policies.

# A Notifier class for sending messages to existing members (e.g. event reminders, etc.)
class UserNotifier < ApplicationNotifier
  def initialize(user)
    @user = user
    super()
  end

  def contactable
    @user
  end

  def prompt_upcoming_event(event)
    send_text { |recipient| EventPromptTexter.new(recipient, event).send_message }
  end

  def send_event_list
    events = @user.events.upcoming.rsvp_required
    send_text { |recipient| EventListTexter.new(recipient, events).send_message }
  end

  def send_help
    send_text { |recipient| HelpTexter.new(recipient).send_message }
  end
end
