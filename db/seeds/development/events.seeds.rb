after "development:units" do
  unit = Unit.first

  # troop meetings
  next_thursday = unit.this_season_starts_at.next_occurring(:thursday).in_time_zone
  33.times do |i|
    unit.events.create!(title:          "Troop Meeting",
                        starts_at:      (next_thursday + i.weeks).change(hour: 19, min: 30),
                        ends_at:        (next_thursday + i.weeks).change(hour: 21, min: 0),
                        event_category: unit.event_categories.find_by(name: "Troop Meeting"))
  end

  # camping trips
  third_friday = unit.this_season_starts_at.next_occurring(:friday).next_occurring(:friday).next_occurring(:friday)
  9.times do |i|
    starts_at = third_friday + (i * 4).weeks
    month = starts_at.month
    next if month == 1

    unit.events.create!(title:          "#{Date::MONTHNAMES[month]} Camping Trip",
                        starts_at:      starts_at.change(hour: 18, min: 0),
                        ends_at:        (starts_at + 2.days).change(hour: 9, min: 0),
                        event_category: unit.event_categories.find_by(name: "Camping Trip"),
                        requires_rsvp:  true)
  end

  puts "#{Event.count} events now exist"
end
