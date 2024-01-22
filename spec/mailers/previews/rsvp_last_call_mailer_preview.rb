# Preview all emails at http://localhost:3000/rails/mailers/rsvp_nag_mailer
class RsvpLastCallMailerPreview < ActionMailer::Preview
  def rsvp_last_call_notification
    recipient = UnitMembership.first
    RsvpLastCallMailer.with(recipient: recipient, event: Event.published.last).rsvp_last_call_notification
  end
end
