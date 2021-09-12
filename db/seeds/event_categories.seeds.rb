# frozen_string_literal: true

EventCategory.find_or_create_by(name: 'Troop Meeting',      glyph: 'user-friends',    color: 'FireBrick')
EventCategory.find_or_create_by(name: 'Camping Trip',       glyph: 'campground',      color: 'Sienna')
EventCategory.find_or_create_by(name: 'Hiking Trip',        glyph: 'hiking',          color: 'ForestGreen')
EventCategory.find_or_create_by(name: 'Court of Honor',     glyph: 'medal',           color: 'Goldenrod')
EventCategory.find_or_create_by(name: 'Service Project',    glyph: 'hand-receiving',  color: 'SteelBlue')
EventCategory.find_or_create_by(name: 'Committee Meeting',  glyph: 'hand-receiving',  color: 'SteelBlue')
