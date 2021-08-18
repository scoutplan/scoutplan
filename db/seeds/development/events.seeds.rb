after 'development:units' do
  unit = Unit.first

  Event.destroy_all

  unit.events.create!([
      { title:  'Troop Meeting',
        starts_at:      5.days.from_now,
        ends_at:        5.days.from_now,
        location:       'Community Center',
        event_category: unit.event_categories.find_by(name: 'Troop Meeting'),
      },
      { title:          'Camping Trip 1',
        starts_at:      14.days.from_now,
        ends_at:        16.days.from_now,
        location:       'State Park',
        event_category: unit.event_categories.find_by(name: 'Camping Trip'),
        requires_rsvp:  true
      },
      { title:          'Camping Trip 2',
        starts_at:      45.days.from_now,
        ends_at:        47.days.from_now,
        location:       'Regional Park',
        event_category: unit.event_categories.find_by(name: 'Troop Meeting'),
        requires_rsvp:  true
      },
      { title:          'Court of Honor',
        starts_at:      76.days.from_now,
        ends_at:        76.days.from_now,
        location:       'Community Center',
        event_category: unit.event_categories.find_by(name: 'Court of Honor'),
        requires_rsvp:  true
      },
      { title:          'Camping Trip 3',
        starts_at:      55.days.from_now,
        ends_at:        57.days.from_now,
        location:       'Scout Camp',
        event_category: unit.event_categories.find_by(name: 'Camping Trip'),
        requires_rsvp:  true
      },
      { title:          'Day Hike',
        starts_at:      70.days.from_now,
        ends_at:        70.days.from_now,
        location:       'Local Mountain',
        event_category: unit.event_categories.find_by(name: 'Hiking Trip'),
        requires_rsvp:  true
      }
    ]
  )

  puts "#{Event.count} events now exist"
end
