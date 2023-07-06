# frozen_string_literal: true

#
# a fallback Mailbox for handling incoming mail where a Unit is known, and not handled elsewhere
# see ApplicationMailbox for routing logic
#
class UnitOverflowMailbox < ApplicationMailbox
  before_processing :find_unit

  def process
    admins = @unit.members.admin
    notification = OverflowMailNotification.with(inbound_email: inbound_email, unit: @unit)
    notification.deliver_later(admins)
  end

  private
    def find_unit
      @unit = EmailEvaluator.new(inbound_email).unit
    end
end
