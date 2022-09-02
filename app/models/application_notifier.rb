# frozen_string_literal: true

# base class for notifiers which are, in turn, wrappers
# around email and text that honor various communication
# preferences.
# The send_email and send_text methods allow us to pass in blocks, and then are responsible
# for honoring business logic and member preferences in a centralized way
class ApplicationNotifier
  protected

  # pipe all email through here to enforce common business rules
  def send_email(&block)
    return unless @member.contactable?
    return unless @member.settings(:communication).via_email

    block.call @member
  end

  # pipe all SMS through here to enforce common business rules
  def send_text(&block)
    return unless member_textable?
    return unless @member.settings(:communication).via_sms

    block.call @member
  rescue StandardError => e
    Rails.logger.error { e.message }
  end

  private

  def member_textable?
    @member.phone.present?
  end
end
