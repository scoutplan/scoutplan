# frozen_string_literal: true

# helpers for Event views
module EventsHelper
  require 'cgi'
  RSVP_GLYPH_CLASSES = { nil => 'ghost', 'accepted' => 'hiking', 'declined' => 'couch' }.freeze
  RSVP_GLYPH_COLORS = { nil => 'text-gray-100', 'accepted' => 'text-green-500', 'declined' => 'text-red-500'}.freeze

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

  # given an EventRsvp object, return a fully-formed span tag containing the correct
  # FontAwesome glphy
  def rsvp_glyph_tag(rsvp)
    glyph_class = RSVP_GLYPH_CLASSES[rsvp&.response]
    text_color = RSVP_GLYPH_COLORS[rsvp&.response]
    title_tag = rsvp.nil? ? 'unknown' : rsvp.response

    content_tag(:span, class: "span.rsvp-response.rsvp-unknown.#{text_color}", title: t("rsvp_#{title_tag}")) do
      content_tag(:i, nil, class: "fad fa-#{glyph_class}")
    end
  end

  def event_badge(event)
    if event.cancelled?
      content_tag(:span, t('events.index.cancelled'), class: 'badge bg-danger ml-2')
    elsif event.draft?
      content_tag(:span, t('events.index.draft'), class: 'badge ml-2 bg-blue-700')
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
