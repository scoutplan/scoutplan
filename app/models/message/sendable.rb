# frozen_string_literal: true

module Message::Sendable
  extend ActiveSupport::Concern

  included do
    after_commit :create_send_job!
  end

  def create_send_job!
    return unless queued? || outbox?

    SendMessageJob.set(wait_until: send_at || Time.now.in_time_zone).perform_later(self, updated_at)
  end

  def mark_as_sent!
    update(status: :sent)
  end

  def send!
    MessageNotification.with(message: self).deliver_later(recipients)
    mark_as_sent!
  end
end
