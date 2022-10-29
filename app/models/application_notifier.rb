# frozen_string_literal: true

# base class for notifiers which are, in turn, wrappers
# around email and text that honor various communication
# preferences.
# The send_email and send_text methods allow us to pass in blocks, and then are responsible
# for honoring business logic and member preferences in a centralized way
class ApplicationNotifier
  attr_accessor :contactable

  protected

  # pipe all email through here to enforce common business rules
  def send_email(&block)
    return unless contactable.contactable?
    return unless contactable.settings(:communication).via_email

    block.call contactable
  end

  # pipe all SMS through here to enforce common business rules
  def send_text(&block)
    return unless contactable.smsable?

    block.call contactable
  rescue StandardError => e
    Rails.logger.error { e.message }
  end

  def contactable
    raise ArgumentError "contactable must be set"
  end
end
