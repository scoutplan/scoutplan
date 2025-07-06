# This module provides functionality for sending messages, including scheduling and marking them as sent
# and associated Message lifecycle hook.
module Message::Sendable
  extend ActiveSupport::Concern

  included do
    after_commit :create_send_job!
  end

  # enqueue the Message to be sent
  def create_send_job!
    return unless queued? || outbox?

    Rails.logger.warn "Creating SendMessageJob for message #{id} with status #{status} and #{message_recipients.count} recipients"
    SendMessageJob.set(wait_until: wait_until).perform_later(self, updated_at)
  end

  def mark_as_sent!
    update(status: :sent)
  end

  # SendMessageJob will call this method to actually send the message. The recipients
  # method can be found in the Notifiable concern, which is probably a code smell.
  def send!
    Rails.logger.warn "Sending message #{id}"
    MessageNotifier.with(message: self).deliver_later(recipients)
    mark_as_sent!
  end

  def wait_until
    return send_at if queued?

    Time.current.in_time_zone
  end
end
