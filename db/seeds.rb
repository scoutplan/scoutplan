# frozen_string_literal: true

# ── Event Categories (all environments) ──────────────────────────────
EventCategory.find_or_create_by(name: "Troop Meeting",      glyph: "user-friends",    color: "FireBrick")
EventCategory.find_or_create_by(name: "Camping Trip",       glyph: "campground",      color: "ForestGreen")
EventCategory.find_or_create_by(name: "Hiking Trip",        glyph: "hiking",          color: "ForestGreen")
EventCategory.find_or_create_by(name: "Court of Honor",     glyph: "medal",           color: "Goldenrod")
EventCategory.find_or_create_by(name: "Service Project",    glyph: "hand-receiving",  color: "SteelBlue")
EventCategory.find_or_create_by(name: "Committee Meeting",  glyph: "users-class",     color: "DarkOrchid")
EventCategory.find_or_create_by(name: "Fundraiser",         glyph: "money-bill-wave", color: "DarkSeaGreen")
EventCategory.find_or_create_by(name: "Aquatic Event",      glyph: "water",           color: "SkyBlue")
EventCategory.find_or_create_by(name: "Cycling",            glyph: "biking",          color: "DodgerBlue")
EventCategory.find_or_create_by(name: "No Meeting",         glyph: "ban",             color: "OrangeRed")
EventCategory.find_or_create_by(name: "Other",              glyph: "calendar-day",    color: "PaleTurqoise")
EventCategory.find_or_create_by(name: "Historical",         glyph: "monument",        color: "maroon")
EventCategory.find_or_create_by(name: "High Adventure",     glyph: "compass",         color: "MediumTurqoise")

return unless Rails.env.development?

# ── Unit ─────────────────────────────────────────────────────────────
Unit.destroy_all
unit = Unit.create!(name: "Troop 123", location: "North Kilttown, IM")
puts "Created #{Unit.count} units"

# ── Users ────────────────────────────────────────────────────────────
User.destroy_all

users_data = [
  { email: "admin@scoutplan.org",  first_name: "Bob",    last_name: "Dobalina",  phone: "500-555-0006" },
  { email: "anne@scoutplan.org",   first_name: "Anne",   last_name: "Avery",     phone: "999-555-1212" },
  { email: "brian@scoutplan.org",  first_name: "Brian",  last_name: "Bosworth",  phone: "999-555-1212" },
  { email: "debbie@scoutplan.org", first_name: "Debbie", last_name: "Doolittle", phone: "999-555-1212" },
  { email: "eric@scoutplan.org",   first_name: "Eric",   last_name: "Einstein",  phone: "999-555-1212" },
  { email: "timmy@scoutplan.org",  first_name: "Timmy",  last_name: "Dobalina",  phone: "999-555-1212" },
  { email: "taylor@scoutplan.org", first_name: "Taylor", last_name: "Dobalina",  phone: "999-555-1212" }
]

users_data.each do |attrs|
  User.create!(password: "password", password_confirmation: "password", **attrs)
end
puts "#{User.count} users now exist"

# ── Unit Memberships ─────────────────────────────────────────────────
User.all.each do |user|
  role = user.email == "admin@scoutplan.org" ? "admin" : "member"
  user.unit_memberships.create!(unit: unit, role: role, status: "active", member_type: "adult")
end
puts "#{UnitMembership.count} unit memberships now exist"

# ── Events ───────────────────────────────────────────────────────────
Event.destroy_all

# Troop meetings — every Tuesday for the current and next season
meeting_category = unit.event_categories.find_by(name: "Troop Meeting")
season_start = unit.this_season_starts_at
season_end   = unit.next_season_ends_at
tuesday = season_start.next_occurring(:tuesday).in_time_zone

while tuesday < season_end
  unit.events.create!(title:          "Troop Meeting",
                      starts_at:      tuesday.change(hour: 19, min: 30),
                      ends_at:        tuesday.change(hour: 21, min: 0),
                      event_category: meeting_category)
  tuesday += 1.week
end

# Camping trips — one per month, September through May, for current and next season
camping_category = unit.event_categories.find_by(name: "Camping Trip")
camping_months = [9, 10, 11, 12, 1, 2, 3, 4, 5]

[unit.this_season_starts_at.year, unit.next_season_starts_at.year].each do |season_year|
  camping_months.each do |month|
    year = month >= 9 ? season_year : season_year + 1
    first_day = Date.new(year, month, 1)
    friday = first_day.next_occurring(:friday)
    third_friday = friday + 2.weeks

    unit.events.create!(title:          "#{Date::MONTHNAMES[month]} Camping Trip",
                        starts_at:      third_friday.in_time_zone.change(hour: 18, min: 0),
                        ends_at:        (third_friday + 2.days).in_time_zone.change(hour: 9, min: 0),
                        event_category: camping_category,
                        requires_rsvp:  true)
  end
end

puts "#{Event.count} events now exist"

# ── RSVPs ────────────────────────────────────────────────────────────
member = UnitMembership.first
event = Event.last
event.event_rsvps.create!(unit_membership: member, response: :declined, respondent: member)
