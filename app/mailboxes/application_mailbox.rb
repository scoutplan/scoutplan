# frozen_string_literal: true

module ActionMailbox
  # KLUDGE ALERT
  # monkey-patch InboundEmail to include our custom evaluator
  class InboundEmail
    attr_reader :evaluator

    def initialize(args)
      super(args)
      @evaluator = EmailEvaluator.new(self)
    end
  end
end

# The ApplicationMailbox is the first mailbox that all incoming email is routed to.
# It is responsible for parsing the recipient address and routing to the appropriate mailbox.
class ApplicationMailbox < ActionMailbox::Base
  # topmost: auto responders are ignored
  routing ->(inbound_email) { inbound_email.evaluator.auto_responder? } => :auto_responder

  # fallback route for unit email
  routing ->(inbound_email) { inbound_email.evaluator.unit? } => :unit_overflow

  # fallback route for anything not handled previously
  routing all: :global_overflow
end
