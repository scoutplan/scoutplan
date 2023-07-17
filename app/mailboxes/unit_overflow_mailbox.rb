# frozen_string_literal: true

#
# a fallback Mailbox for handling incoming mail where a Unit is known, and not handled elsewhere
# see ApplicationMailbox for routing logic
#
class UnitOverflowMailbox < ApplicationMailbox
  def process
    unit = inbound_email.evaluator.unit
    admins = unit.members.admin
    notification = OverflowMailNotification.with(inbound_email: inbound_email, unit: inbound_email.evaluator.unit)
    notification.deliver_later(admins)
  end
end
