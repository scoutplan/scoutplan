# frozen_string_literal: true

module EventsHelper
  require "cgi"
  RSVP_GLYPH_CLASSES = { nil => "ghost", "accepted" => "hiking", "declined" => "couch" }.freeze
  RSVP_GLYPH_COLORS = { nil => "text-gray-100", "accepted" => "text-green-500", "declined" => "text-red-500"}.freeze
  MAP_BASE_URL = "https://www.google.com/maps/"
  CLASS_GLYPH_WRAPPER = "event-category-glyph"

  # given an Event, return a FontAwesome-formatted <i> tag corresponding to
  # the associated EventCategory
  def glyph_tag(event, **options)
    ap options[:classes]

    style = options[:exclude_color] ? "" : "color:#{event&.category&.color}"
    classes = "fa-solid mr-1 fa-fw fa-#{event&.category&.glyph} #{options[:classes]}}"

    content_tag(:span, class: CLASS_GLYPH_WRAPPER) do
      content_tag(
        :i,
        nil,
        class: classes,
        style: style,
        title: event&.event_category&.name
      )
    end
  end

  def row_classes(event)
    result = []
    result << "event-past" if event.ends_at.past?
    result << "event-future" if event.starts_at > 3.months.from_now
    result << "event-rsvp"   if event.requires_rsvp
    result << "event-draft"  if event.draft?
    result << "event-cancelled" if event.cancelled?

    result.join(" ")
  end

  # given an EventRsvp object, return a fully-formed span tag containing the correct
  # FontAwesome glphy
  def rsvp_glyph_tag(member, rsvp)
    glyph_class = RSVP_GLYPH_CLASSES[rsvp&.response]
    text_color = RSVP_GLYPH_COLORS[rsvp&.response]
    title_tag = rsvp.nil? ? "unknown" : rsvp.response
    first_name = member.display_first_name

    content_tag(
      :span,
      class: "span.rsvp-response.rsvp-unknown.#{text_color}",
      title: "#{first_name}: " + t("rsvp_#{title_tag}")
    ) do
      content_tag(:i, nil, class: "fad fa-#{glyph_class}")
    end
  end

  # given an Event, return an appropriate pill_tag, if needed
  def event_badge(event)
    if event.cancelled?
      pill_tag("Cancelled", "bg-red-500 text-white font-bold uppercase tracking-wider")
    elsif event.draft?
      pill_tag("Draft", "bg-white text-sky-500 border border-sky-500 font-bold uppercase tracking-wider")
    end
  end

  # given an Event, generate a Google Maps URL. Assumes the Event has
  # at least a destination
  def event_map_url(event)
    parts = if (departure_address = event.full_address(:departure)).present?
              ["dir", departure_address, event.full_address(:arrival), event.full_address(:activity)]
            else
              ["search", event.mapping_address]
            end
    parts.compact!
    search_path = parts.map { |m| CGI.escape(m.gsub(",", "")) }.join("/")
    [MAP_BASE_URL, search_path].join
  end

  def link_name(url)
    return "Zoom" if zoom_link?(url)

    "Link"
  end

  def zoom_link?(url)
    url =~ %r{https://.*\.zoom.us/j/.*}
  end
end
