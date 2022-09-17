# frozen_string_literal: true

namespace :scoutplan do
  desc "Create event locations"
  task create_event_locations: :environment do
    puts "Processing #{Event.count} events..."
    location_count = Location.count
    Event.all.each do |event|
      puts ""
      puts "Processing #{event.title} on #{event.starts_at}..."

      # origin
      if event.departs_from.present?
        Location.create_with(locatable: event,
                             address: event.departs_from).find_or_create_by(key: "departure")
        puts "Created departure location".purple
      else
        puts "Skipping departure location"
      end

      if event.location.present? || event.address.present? || event.venue_phone.present?
        Location.create_with(locatable: event,
                             name: event.location,
                             address: event.address,
                             phone: event.venue_phone).find_or_create_by(key: "arrival")
        puts "Created arrival location".blue
      else
        puts "Skipping arrival location"
      end
    end
    puts "Created #{Location.count - location_count} Locations"
  end
end
