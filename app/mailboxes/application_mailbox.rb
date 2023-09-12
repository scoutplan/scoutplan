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

class ApplicationMailbox < ActionMailbox::Base
  routing ->(inbound_email) { inbound_email.evaluator.auto_responder? }  => :auto_responder
  routing ->(inbound_email) { inbound_email.evaluator.event.present? }   => :event
  routing ->(inbound_email) { inbound_email.evaluator.message.present? } => :message
  routing ->(inbound_email) { inbound_email.evaluator.unit.present? }    => :unit
  routing all: :global_overflow
end
