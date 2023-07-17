class UnitMailbox < ApplicationMailbox
  routing ->(inbound_email) { inbound_email.evaluator.event.present? } => :event
  routing ->(inbound_email) { inbound_email.evaluator.modifier.present? } => :unit_list
  routing ->(_inbound_email) { true } => :unit_overflow
end
