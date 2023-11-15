# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/AbcSize
class EventRsvpMailerPreview < ActionMailer::Preview
  def event_rsvp_notification
    setup
    EventRsvpMailer.with(event_rsvp: @event_rsvp, recipient: @event_rsvp.member).event_rsvp_notification
  end

  def event_rsvp_notification_rsvp_closed
    perform_enqueued_jobs do
      @event_rsvp = FactoryBot.create(:event_rsvp, response: "accepted")
      @event = @event_rsvp.event
      @event.update(status: "published", requires_rsvp: true, rsvp_closes_at: 2.days.ago)
      @organizer = FactoryBot.create(:member, unit: @event.unit)
      @unit = @event.unit
      @location = FactoryBot.create(:location, unit: @unit)
      @event.event_locations.create(location_type: "departure", location: @location)
      @event.event_organizers.create(member: @organizer, role: "organizer")
      @event.generate_static_map
      EventRsvpMailer.with(event_rsvp: @event_rsvp).event_rsvp_notification
    end
  end

  def event_rsvp_delegate_notification
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

  def event_rsvp_youth_accepted_pending
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

  def event_rsvp_youth_accepted_pending_single_parent
    @event_rsvp = FactoryBot.create(:event_rsvp, response: "accepted_pending")
    @member = @event_rsvp.member
    @member.update(member_type: "youth")

    parent = FactoryBot.create(:member, unit: @member.unit)
    @member.parent_relationships.create(parent_unit_membership: parent)

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

  def event_rsvp_youth_declined_pending
    @event_rsvp = FactoryBot.create(:event_rsvp, response: "declined_pending")
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

  private

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

  def setup
    @event_rsvp = FactoryBot.create(:event_rsvp, response: "accepted", unit: Unit.first)
    @event = @event_rsvp.event
    @unit = @event_rsvp.unit

    # organizer
    @organizer = FactoryBot.create(:member, unit: @unit)
    @event.event_organizers.create!(member: @organizer, role: "organizer", assigned_by: @organizer)

    # locations
    @location = FactoryBot.create(:location, unit: @unit)
    @event.event_locations.create(location_type: "departure", location: @location)
    @event.generate_static_map

    # rsvp closure
    @event.rsvp_closes_at = Time.zone.now + 1.day
  end
end
# rubocop:enable Metrics/ClassLength
# rubocop:enable Metrics/AbcSize
