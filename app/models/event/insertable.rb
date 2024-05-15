# frozen_string_literal: true

module Event::Insertable
  INSERTED_EVENT_TITLE = "New Event"
  WEEKEND_START_HOUR = 9
  WEEKEND_END_HOUR_SINGLE_DAY = 17
  WEEKEND_END_HOUR_MULTIPLE_DAYS = 9

  extend ActiveSupport::Concern

  def new_event_before
    unit.events.new(
      title:          predicted_event_title,
      starts_at:      inserted_starts_at,
      ends_at:        inserted_ends_at,
      event_category: predicted_event_category,
      status:         "draft"
    )
  end

  def previous_last_week?
    previous.starts_at < starts_at.prev_occurring(:saturday)
  end

  def inserted_starts_at
    return starts_at - 1.week if previous.nil?
    return starts_at.prev_occurring(:saturday).change(hour: WEEKEND_START_HOUR) if previous_last_week?

    starts_at - 1.week
  end

  def inserted_ends_at
    return ends_at - 1.week if previous.nil?
    return starts_at.prev_occurring(:sunday).change(hour: WEEKEND_END_HOUR_MULTIPLE_DAYS) if previous_last_week?

    ends_at - 1.week
  end

  def predicted_event_category
    return event_category if previous.nil?
    return weekend_category if previous_last_week?

    previous.event_category
  end

  def predicted_event_title
    return INSERTED_EVENT_TITLE if previous.nil?
    return weekend_category.name if previous_last_week?

    previous.category.name
  end

  def weekend_category
    unit.categories.where("name ILIKE ?", "%camping%")&.first || category
  end
end
