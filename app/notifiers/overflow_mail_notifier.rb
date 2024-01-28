class OverflowMailNotifier < Noticed::Event
  deliver_by :email, mailer: "OverflowMailer", method: :overflow_notification

  required_params :inbound_email, :unit
end
