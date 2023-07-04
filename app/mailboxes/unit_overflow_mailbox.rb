# frozen_string_literal: true

#
# a fallback Mailbox for handling incoming mail where a Unit is known, and not handled elsewhere
# see ApplicationMailbox for routing logic
#
class UnitOverflowMailbox < ApplicationMailbox
  def process
    Rails.logger.warn "Processing overflow mail for unit #{@unit}"
    admins = @unit.members.admin.active?
    Rails.logger.warn "Found #{admins.count} admins"
    notification = OverflowMailNotification.with(inbound_email: inbound_email, unit: @unit)
    notification.deliver_later(admins)
  end
end
