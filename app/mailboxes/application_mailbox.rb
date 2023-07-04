# frozen_string_literal: true

# The ApplicationMailbox is the first mailbox that all incoming email is routed to.
# It is responsible for parsing the recipient address and routing to the appropriate mailbox.
class ApplicationMailbox < ActionMailbox::Base
  before_processing :parse_recipient
  before_processing :find_unit

  routing ->(inbound_email) { Rails.logger.warn("$$$ #{@unit&.name}"); @unit.present? } => :unit_overflow # fallback route for all email where a unit is identified
  routing :all => :global_overflow # fallback route for any email remaining

  protected
    # After parsing the recipient address, find the unit that the email is being sent to.
    # Note that not all email will route to a unit, so this may be nil.
    def find_unit
      @unit = Unit.find_by(slug: @slug)
      Rails.logger.warn "Unit: #{@unit}"
    end

    # Given an inbound email address, extract the slug from the recipient address
    # example:
    # slug_from_recipient("troop28sanandreas@mail.scoutplan.org") => "troop28sanandreas"
    def parse_recipient
      Rails.logger.warn "Inbound email: #{mail.to.first}"
      sender = mail.to.first.split("@").first
      sender_parts = sender.split(".")
      @slug = sender_parts.first
      @modifiers = sender_parts.drop(1)
    end
end
