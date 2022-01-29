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
        class: "text-center fad fa-#{event.category.glyph}",
        style: "color:#{event.category.color}",
        title: event.event_category.name
      )
    end
  end

  # can a given member cancel a given event?
  def event_cancellable?(event, member)
    !@event.new_record? && EventPolicy.new(event, member).cancel?
  end

  # given an EventRsvp object, return a fully-formed span tag containing the correct
  # FontAwesome glphy
  def rsvp_glyph_tag(member, rsvp)
    glyph_class = RSVP_GLYPH_CLASSES[rsvp&.response]
    text_color = RSVP_GLYPH_COLORS[rsvp&.response]
    title_tag = rsvp.nil? ? 'unknown' : rsvp.response
    first_name = member.display_first_name

    content_tag(
      :span,
      class: "span.rsvp-response.rsvp-unknown.#{text_color}",
      title: "#{first_name}: " + t("rsvp_#{title_tag}")
    ) do
      content_tag(:i, nil, class: "fad fa-#{glyph_class}")
    end
  end

  def event_badge(event)
    common_classes = 'rounded px-2 py-1 text-xs tracking-wide font-bold text-white ml-2'
    title = "Only visible to #{event.unit.name} administrators, like you."
    if event.cancelled?
      content_tag :span, t('events.index.cancelled'), class: "#{common_classes} bg-red-500", title: title
      content_tag :i, nil, class: 'fas fa-times-hexagon text-red-500 ml-2', title: "Cancelled"
    elsif event.draft?
      content_tag :i, nil, class: 'fas fa-ruler-triangle text-sky-500 ml-2', title: "Draft event, #{title.downcase}"
    end
  end

  # given an Event, generate a Google Maps URL. Assumes the Event has
  # at least a destination
  def event_map_url(event)
    base_url = 'https://www.google.com/maps/'
    parts = event.departs_from.present? ? ['dir', event.departs_from, event.destination] : ['search', event.destination]
    search_path = parts.map { |m| CGI.escape(m.gsub(',', '')) }.join('/')
    [base_url, search_path].join
  end
end
