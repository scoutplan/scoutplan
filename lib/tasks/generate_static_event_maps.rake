# frozen_string_literal: true

namespace :sp do
  desc "Generate static maps for all events"
  task generate_static_event_maps: :environment do
    events = Event.all
    events.each(&:enqueue_static_map_job)
    puts "Enqueued #{events.count} static map jobs"
  end
end
