# Preview all emails at http://localhost:3000/rails/mailers/organizer
class OrganizerPreview < ActionMailer::Preview
  def daily_digest_email
    unit = Unit.first
    organizer = unit.members.first
    event = unit.events.future.first
    event.rsvps.find_or_create_by(unit_membership: organizer, response: "accepted", respondent: organizer)
    new_rsvps = event.rsvps.group_by(&:response)

    OrganizerMailer.with(event: event, organizer: organizer, new_rsvps: new_rsvps).daily_digest_email
  end
end
