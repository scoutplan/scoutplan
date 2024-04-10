# frozen_string_literal: true

class Mailgun::FailureHandler
  attr_reader :data, :reason, :user

  def initialize(data)
    @data = data
    @reason = data["reason"]
  end

  def process
    return unless reason == "suppress-bounce"

    recipient_address = data.dig("message", "headers", "to")
    @user = User.find_by(email: recipient_address)
    return unless @user

    user&.disable_delivery!(method: :email)
    notify_admins
  end

  def notify_admins
    return unless user.present?

    admins = user.units&.collect{ |u| u.members.admin }.flatten
    FailedEmailNotifier.with(self).deliver_later(admins)
  end
end
