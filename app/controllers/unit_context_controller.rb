# 

class UnitContextController < ApplicationController
  def current_unit
    unit = Unit.new(id: 1)

    unit.events.build([
      { id: 1, title: 'Troop Meeting',
        starts_at: 5.days.from_now,
        ends_at: 5.days.from_now,
        location: 'Community Center'
      },
      { id: 2,
        title: 'Camping Trip',
        starts_at: 14.days.from_now,
        ends_at: 16.days.from_now,
        location: 'State Park'
      },
      { id: 3,
        title: 'Camping Trip',
        starts_at: 45.days.from_now,
        ends_at: 47.days.from_now,
        location: 'Scout Camp'
      }
    ])

    unit
  end
end
