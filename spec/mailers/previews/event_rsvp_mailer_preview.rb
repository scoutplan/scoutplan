# frozen_string_literal: true

class EventRsvpMailerPreview < ActionMailer::Preview
  def event_rsvp_notification
    around_email do
      @event_rsvp = FactoryBot.create(:event_rsvp, response: "accepted")
      @event = @event_rsvp.event
      @event.update(status: "published", requires_rsvp: true)
      @organizer = FactoryBot.create(:member, unit: @event.unit)
      @unit = @event.unit
      @location = FactoryBot.create(:location, unit: @unit)
      @event.event_locations.create(location_type: "departure", location: @location)
      @event.event_organizers.create(member: @organizer, role: "organizer")
      @event.rsvp_closes_at = Time.zone.now + 1.day
      # EventReminderMailer.with(event: event, recipient: recipient).event_reminder_notification
      EventRsvpMailer.with(event_rsvp: @event_rsvp).event_rsvp_notification
    end
  end

  def event_rsvp_delegate_notification
    around_email do
      @event_rsvp = FactoryBot.create(:event_rsvp, response: "accepted")
      @event = @event_rsvp.event
      @event.update(status: "published", requires_rsvp: true)
      @organizer = FactoryBot.create(:member, unit: @event.unit)

      @event_rsvp.update(respondent: @organizer)

      @unit = @event.unit
      @location = FactoryBot.create(:location, unit: @unit)
      @event.event_locations.create(location_type: "departure", location: @location)
      @event.event_organizers.create(member: @organizer, role: "organizer")
      @event.rsvp_closes_at = Time.zone.now + 1.day
      # EventReminderMailer.with(event: event, recipient: recipient).event_reminder_notification
      EventRsvpMailer.with(event_rsvp: @event_rsvp).event_rsvp_notification
    end
  end  

  private

  # rubocop:disable Lint/SuppressedException
  def around_email
    message = nil
    begin
      ActiveRecord::Base.transaction do
        message = yield
        message.to_s
        raise ActiveRecord::Rollback
      end
    rescue ActiveRecord::Rollback
    end
    message
  end
  # rubocop:enable Lint/SuppressedException
end
