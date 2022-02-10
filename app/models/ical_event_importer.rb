# frozen_string_literal: true

require "icalendar"
require "net/http"
require "uri"

class IcalEventImporter
  def initialize
    @source_url = ENV["ICAL_URL"]
  end

  # https://github.com/icalendar/icalendar#parsing-icalendars
  def import
    cal_file = Net::HTTP.get(URI.parse(@source_url))
    cals = Icalendar::Calendar.parse(cal_file)
    calendar = cals.first

    calendar.events.each do |event|
      # next unless event.dtstart.future?
      ap event.dtstart
      ap event.summary
      ap event.location
      ap event.rrule
      ap event.uid
    end
  end
end
