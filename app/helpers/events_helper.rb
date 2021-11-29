# frozen_string_literal: true

# helpers for Event views
module EventsHelper
  require 'cgi'

  def glyph_tag(event)
    content_tag(:span, class: 'event-category-glyph') do
      content_tag(
        :i,
        nil,
        class: "fad fa-#{event.event_category.glyph}",
        style: "color: #{event.event_category.color}",
        title: event.event_category.name
      )
    end
  end

  def event_badge(event)
    if event.cancelled?
      content_tag(:span, t('events.index.cancelled'), class: 'badge bg-danger ml-2')
    elsif event.draft?
      content_tag(:span, t('events.index.draft'), class: 'badge bg-secondary ml-2')
    end
  end

  def event_map_url(event)
    base_url = "https://www.google.com/maps"
    return "#{base_url}/dir/#{event_location_string(event.departs_from)}/#{event_location_string(event.address)}" \
      if event.departs_from.present? && event.address.present?
    return "#{base_url}/dir/#{event_location_string(event.departs_from)}/#{event_location_string(event.location)}" \
      if event.departs_from.present? && event.location.present?
    return "#{base_url}/search/#{event_location_string(event.address)}" if event.address.present?
    return "#{base_url}/search/#{event_location_string(event.location)}" if event.location.present?

    return ""
  end

  def event_location_string(str)
    str.gsub!(',', '')
    CGI.escape(str)
  end
end
