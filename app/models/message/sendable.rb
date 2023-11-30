module Message::Sendable
  extend ActiveSupport::Concern

  included do
    after_commit :create_send_job!
  end

  def create_send_job!
    return unless queued? || outbox?

    SendMessageJob.set(wait_until: wait_until).perform_later(self, updated_at)
  end

  def mark_as_sent!
    update(status: :sent)
  end

  def send!
    Rails.logger.warn "Sending message #{id}"
    MessageNotification.with(message: self).deliver_later(recipients)
    mark_as_sent!
  end

  def wait_until
    return send_at if queued?

    Time.current.in_time_zone
  end
end
