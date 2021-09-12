# frozen_string_literal: true

class EventNotifier
  def rsvp_opening(user); end

  def invitation_email(token)
    EventMailer.with(token: token).invitation_email.deliver_later
  end
end
