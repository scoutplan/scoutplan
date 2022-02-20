# frozen_string_literal: true

# wrapper for Mixpanel tracker
class Tracker
  def initialize(member = nil)
    @member = member
    @tracker = Mixpanel::Tracker.new(ENV["MIXPANEL_TOKEN"])
    track_member
  end

  def track_activity(event = nil, properties = {})
    return unless event

    @tracker.track(@member&.id || -1, event)
  end

  private

  def track_member
    return unless @member

    @tracker.people.set(
      @member.id,
      {
        "$first_name" => @member.first_name,
        "$last_name" => @member.last_name,
        "$email" => @member.email,
        "$unit" => [ @member.unit.name, @member.unit.location].join(" ")
      }
    )
  end
end