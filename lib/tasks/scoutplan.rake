# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
namespace :sp do
  # desc "Convert Locations to EventLocations"
  # task normalize_locations: :environment do
  #   EventLocation.destroy_all

  #   Location.all.each do |location|
  #     event = location.locatable
  #     event.event_locations.create!(location: location, location_type: location.key)
  #   end
  # end

  # desc "Create event locations"
  # task create_event_locations: :environment do
  #   puts "Processing #{Event.count} events..."
  #   location_count = Location.count
  #   Event.all.each do |event|
  #     puts ""
  #     puts "Processing #{event.title} on #{event.starts_at}..."

  #     # origin
  #     if event.departs_from.present?
  #       Location.create_with(address: event.departs_from).find_or_create_by(key: "departure", locatable: event)
  #       puts "Created departure location".purple
  #     else
  #       puts "Skipping departure location"
  #     end

  #     if event["location"].present? || event["address"].present? || event["venue_phone"].present?
  #       Location.create_with(name: event.location,
  #                            address: event.address,
  #                            phone: event.venue_phone).find_or_create_by(key: "arrival", locatable: event)
  #       puts "Created arrival location".blue
  #     else
  #       puts "Skipping arrival location"
  #     end
  #   end
  #   puts "Created #{Location.count - location_count} Locations"
  # end

  # desc "Create organizer digest tasks"
  # task add_organizer_digest_tasks: :environment do
  #   Unit.all.each do |unit|
  #     task = unit.tasks.create!(key: "EventOrganizerDigestTask", type: "EventOrganizerDigestTask")
  #     rule = IceCube::Rule.daily.hour_of_day(18).minute_of_hour(0)
  #     task.clear_schedule
  #     task.schedule.start_time = DateTime.now.in_time_zone # this should put IceCube into the unit's local time zone
  #     task.schedule.add_recurrence_rule rule
  #     task.save_schedule
  #   end
  # end

  desc "Flag existing SMS recipients as having received intro messages"
  task flag_existing_sms_recipients: :environment do
    User.where.not(phone: nil).each do |user|
      user.settings(:communication).intro_sms_sent = true
      user.save!
    end
  end

  desc "Upgrade EventRsvpOrganizerNotification objects"
  task upgrade_event_rsvp_organizer_notifications: :environment do
    UnitMembership.all.each do |member|
      member.notifications.where(type: "EventRsvpOrganizerNotification").each do |notification|
        notification.record = notification.params[:event]
        notification.save!
      end
    end
  end

  namespace :members do
    desc "Compute contactability for all unit memberships"
    task compute_contactability: :environment do
      UnitMembership.find_each do |membership|
        membership.compute_contactability!
      rescue StandardError => e
        puts "Error computing contactability for membership #{membership.id}: #{e.message}"
      end
    end
  end

  # desc "Advance events by one month"
  # task advance_events: :environment do
  #   unit_id = ENV["SP_ADVANCE_UNIT_ID"]
  #   unless unit_id
  #     puts "Please set SP_ADVANCE_UNIT_ID"
  #     exit
  #   end

  #   unit = Unit.find(unit_id)
  #   unless unit.present?
  #     puts "Unit #{unit_id} not found"
  #     exit
  #   end

  #   puts "Advancing events for #{unit.name} by one month. Proceed? [Y/N]"
  #   response = STDIN.gets.chomp.upcase
  #   unless response == "Y"
  #     puts "Aborting"
  #     exit
  #   end

  #   # do the deed
  #   unit.events.each do |event|
  #     event.starts_at += 4.weeks
  #     event.ends_at += 4.weeks
  #     event.rsvp_closes_at += 4.weeks
  #     event.save!
  #   end
  # end
end
# rubocop:enable Metrics/BlockLength
