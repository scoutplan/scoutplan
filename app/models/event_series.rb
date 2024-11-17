class EventSeries
  # rubocop:disable Metrics/AbcSize
  def self.create_with(from_event, repeats_until: nil, repeat_count: nil)
    repeat_count ||= (repeats_until.to_date - from_event.starts_at.to_date).to_i / 7
    repeat_count.times do |index|
      new_event = from_event.dup
      new_event.update!(
        starts_at:     from_event.starts_at + (index + 1).weeks,
        ends_at:       from_event.ends_at + (index + 1).weeks,
        series_parent: from_event,
        repeats_until: nil,
        token:         Event.generate_unique_secure_token
      )
    end
  end
  # rubocop:enable Metrics/AbcSize
end
