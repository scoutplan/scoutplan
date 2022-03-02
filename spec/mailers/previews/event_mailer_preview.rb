# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/event

require "faker"
require "factory_bot"

class EventMailerPreview < ActionMailer::Preview
  def cancellation_email
    unit = Unit.first
    member = unit.members.first
    event = FactoryBot.build(:event, :published, unit: unit)
    note = "Schade. Dass tut mir leid!"
    EventMailer.with(event: event, member: member, note: note).cancellation_email
  end

  def cancellation_email_no_note
    unit = Unit.first
    member = unit.members.first
    event = FactoryBot.build(:event, :published, unit: unit)
    note = ""
    EventMailer.with(event: event, member: member, note: note).cancellation_email
  end

  def token_invitation_email
    unit = Unit.new(name: 'Test Unit')
    event = Event.new(title: 'Test Event', unit: unit, description: "I'm baby williamsburg pabst master cleanse, gentrify letterpress yr kogi. Taiyaki air plant austin four dollar toast post-ironic humblebrag keffiyeh tofu palo santo bushwick locavore everyday carry shoreditch tbh. Bicycle rights helvetica bitters cray sartorial ramps literally raclette. Kitsch YOLO normcore single-origin coffee artisan literally, offal umami VHS poutine direct trade vexillologist banh mi. Fanny pack food truck health goth actually jianbing mixtape, typewriter woke gastropub tbh beard ennui. Small batch chia authentic craft beer cred.")
    user = User.new(first_name: 'Test', last_name: 'User')
    member = unit.unit_memberships.build(user: user)
    token = RsvpToken.new(event: event, member: member)
    EventMailer.with(token: token, member: member).token_invitation_email
  end

  def rsvp_confirmation_email
    rsvp = EventRsvp.first
    EventMailer.with(rsvp: rsvp, member: rsvp.member).rsvp_confirmation_email
  end
end
