class ScoutplanMailDeliveryJob < ActionMailer::MailDeliveryJob
  discard_on Postmark::InactiveRecipientError
end
