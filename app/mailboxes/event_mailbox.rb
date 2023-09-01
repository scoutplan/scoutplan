# frozen_string_literal: true

class EventMailbox < ApplicationMailbox
  def process
    @event = inbound_email.evaluator.event
    return unless @event.present?

    routing ->(inbound_email) { inbound_email.evaluator.rsvp.present? } => :rsvp
  end
end
