# frozen_string_literal: true

class EventRsvpMailerPreview < ActionMailer::Preview
  # rubocop:disable Metrics/AbcSize

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
      EventRsvpMailer.with(event_rsvp: @event_rsvp).event_rsvp_notification
    end
  end

  def event_rsvp_youth_pending
    around_email do
      @event_rsvp = FactoryBot.create(:event_rsvp, response: "accepted_pending")
      @member = @event_rsvp.member
      @member.update(member_type: "youth")
      2.times do
        parent = FactoryBot.create(:member, unit: @member.unit)
        @member.parent_relationships.create(parent_unit_membership: parent)
      end

      @event = @event_rsvp.event
      @event.update(status: "published", requires_rsvp: true)
      @organizer = FactoryBot.create(:member, unit: @event.unit)

      @event_rsvp.update(respondent: @member)

      @unit = @event.unit
      @location = FactoryBot.create(:location, unit: @unit)
      @event.event_locations.create(location_type: "departure", location: @location)
      @event.event_organizers.create(member: @organizer, role: "organizer")
      @event.rsvp_closes_at = Time.zone.now + 1.day
      EventRsvpMailer.with(event_rsvp: @event_rsvp).event_rsvp_notification
    end
  end

  # rubocop:enable Metrics/AbcSize

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
