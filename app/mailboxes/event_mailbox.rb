# frozen_string_literal: true

class EventMailbox < ApplicationMailbox
  routing ->(inbound_email) { inbound_email.evaluator.rsvp.present? } => :rsvp

  def process
    @event = inbound_email.evaluator.event
  end
end
