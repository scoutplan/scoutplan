after :units do
  unit = Unit.first

  Event.destroy_all

  unit.events.create([
      { title:  'Troop Meeting',
        starts_at:     5.days.from_now,
        ends_at:       5.days.from_now,
        location:      'Community Center',
        category:      'troop_meeting'
      },
      { title:         'Camping Trip',
        starts_at:     14.days.from_now,
        ends_at:       16.days.from_now,
        location:      'State Park',
        category:      'camping',
        requires_rsvp: true
      },
      { title:         'Camping Trip',
        starts_at:     45.days.from_now,
        ends_at:       47.days.from_now,
        location:      'Scout Camp',
        category:      'camping',
        requires_rsvp: true
      },
      { title:         'Court of Honor',
        starts_at:     76.days.from_now,
        ends_at:       76.days.from_now,
        location:      'Community Center',
        category:      'court_of_honor',
        requires_rsvp: true
      },
      { title:         'Camping Trip',
        starts_at:     55.days.from_now,
        ends_at:       57.days.from_now,
        location:      'Scout Camp',
        category:      'camping',
        requires_rsvp: true
      }]
    )
end
