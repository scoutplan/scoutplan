# Preview all emails at http://localhost:3000/rails/mailers/rsvp_nag_mailer
class RsvpNagMailerPreview < ActionMailer::Preview
  def rsvp_nag_notification
    recipient = UnitMembership.first
    RsvpNagMailer.with(recipient: recipient, event: Event.last).rsvp_nag_notification
  end
end
