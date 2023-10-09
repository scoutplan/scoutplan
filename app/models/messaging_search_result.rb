# frozen_string_literal: true

class MessagingSearchResult
  include ActionView::Helpers

  attr_accessor :result

  delegate_missing_to :result

  def initialize(result)
    @result = result
  end

  def key
    return "dl_#{@result.key}" if @result.is_a?(DistributionList)
    return "membership_#{id}" if @result.is_a?(UnitMembership)
    return "event_#{id}" if @result.is_a?(Event)
  end

  def contactable?
    return @result.contactable? if @result.respond_to?(:contactable?)
    return true if @result.is_a?(Event) && @result.rsvps.count.positive?

    false
  end

  def self.to_a(results)
    results.map { |r| MessagingSearchResult.new(r) }
  end

  def email
    @result.emailable? ? @result.email : "No email address on file"
  end

  def contactable_status
    contactable? ? "contactable" : "not-contactable"
  end

  def name
    return @result.name if @result.respond_to?(:name)
    return "#{@result.title} Attendees" if @result.is_a?(Event)
    return full_display_name if @result.respond_to?(:full_display_name)
  end

  def description
    return event_description if @result.is_a?(Event)
    return @result.description if @result.respond_to?(:description)
    return unit_membership_description if @result.is_a?(UnitMembership)

    "No description"
  end

  private

  def unit_membership_description
    return "No contact methods available" unless contactable?

    result = []
    result << @result.email if @result.emailable?
    result << @result.phone.phony_formatted(country_code: "US") if @result.smsable?
    result.compact.join(" &middot; ")
  end

  def event_description
    attendee_count = @result.rsvps.accepted.select { |r| r.member.contactable? }.count

    if @result.ended?
      "#{pluralize(attendee_count, 'contactable attendee')}, ended #{ApplicationController.helpers.deictic_string_for_time_interval_from_day(@result.ends_at)}"
    else
      "#{pluralize(attendee_count, 'contactable attendee')}, starts #{ApplicationController.helpers.deictic_string_for_time_interval_from_day(@result.starts_at)}"
    end
  end
end
