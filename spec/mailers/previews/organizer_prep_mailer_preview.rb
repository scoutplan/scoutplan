# frozen_string_literal: true

class OrganizerPrepMailerPreview < ActionMailer::Preview
  def organizer_prep_notification
    recipient = UnitMembership.first
    OrganizerPrepMailer.with(recipient: recipient, event: Event.published.last).organizer_prep_notification
  end
end
