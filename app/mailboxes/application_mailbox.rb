# frozen_string_literal: true

# Extend InboundEmail to add an evaluator method so that we can analyze the email
# before hitting the routing rules.
module ActionMailbox
  InboundEmail.class_eval do
    def evaluator
      @evaluator ||= EmailEvaluator.new(self)
    end
  end
end

# The ApplicationMailbox is the first mailbox that all incoming email is routed to.
# It is responsible for parsing the recipient address and routing to the appropriate mailbox.
class ApplicationMailbox < ActionMailbox::Base
  # topmost: auto responders are ignored
  routing ->(inbound_email) { inbound_email.evaluator.auto_responder? } => :auto_responder

  # if an Event is found, route to the EventMailbox
  routing ->(inbound_email) { inbound_email.evaluator.event.present? } => :event

  # if a Unit is found, route to the UnitMailbox
  routing ->(inbound_email) { inbound_email.evaluator.unit.present? } => :unit

  # fallback route for anything not handled previously
  routing all: :global_overflow
end
