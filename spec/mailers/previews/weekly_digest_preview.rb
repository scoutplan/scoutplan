# Preview all emails at http://localhost:3000/rails/mailers/weekly_digest
class WeeklyDigestPreview < ActionMailer::Preview
  # rubocop:disable Metrics/AbcSize
  def notification
    around_email do
      unit = Unit.first
      recipient = unit.members.first
      unit.events.create!(
        title: "Camping Trip",
        starts_at: 36.hours.from_now,
        ends_at: 60.hour.from_now,
        status: "published",
        requires_rsvp: true,
        event_category: unit.event_categories.first
      )

      event = unit.events.create!(
        title: "Camping Trip 2",
        starts_at: 36.hours.from_now,
        ends_at: 60.hour.from_now,
        status: "published",
        requires_rsvp: true,
        event_category: unit.event_categories.first,
        cost_adult: 20.00,
        cost_youth: 20.00
      )
      event.rsvps.create_with(response: "accepted", respondent: recipient).find_or_create_by!(unit_membership: recipient)

      event = unit.events.create!(
        title: "Camping Trip 3",
        starts_at: 48.hours.from_now,
        ends_at: 72.hour.from_now,
        status: "published",
        requires_rsvp: true,
        event_category: unit.event_categories.first,
        cost_adult: 20.00,
        cost_youth: 20.00
      )
      event.rsvps.create_with(response: "accepted", respondent: recipient).find_or_create_by!(unit_membership: recipient)
      event.payments.create!(unit_membership: recipient, amount: 2000)

      WeeklyDigestMailer.with(recipient: recipient, unit: unit).weekly_digest_notification
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
