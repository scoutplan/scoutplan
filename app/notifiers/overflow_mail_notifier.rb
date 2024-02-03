class OverflowMailNotifier < Noticed::Event
  deliver_by :email do |config|
    config.mailer = "OverflowMailer"
    config.method = :overflow_notification
    config.if = :email?
  end

  required_params :inbound_email, :unit
end
