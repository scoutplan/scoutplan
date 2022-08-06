# frozen_string_literal: true

# helpers for Event views
module EventsHelper
  require "cgi"
  RSVP_GLYPH_CLASSES = { nil => "ghost", "accepted" => "hiking", "declined" => "couch" }.freeze
  RSVP_GLYPH_COLORS = { nil => "text-gray-100", "accepted" => "text-green-500", "declined" => "text-red-500"}.freeze
  MAP_BASE_URL = "https://www.google.com/maps/"

  # given an Event, return a FontAwesome-formatted <i> tag corresponding to
  # the associated EventCategory
  def glyph_tag(event)
    content_tag(:span, class: "event-category-glyph") do
      content_tag(
        :i,
        nil,
        class: "text-center fad fa-#{event.category.glyph}",
        style: "color:#{event.category.color}",
        title: event.event_category.name
      )
    end
  end

  # given an Event, return a space-delimited string of classes to apply to a table row
  # in the Events#index view
  def row_classes(event)
    result = []
    result << "event-past" if event.ends_at.localtime.past?
    result << "event-future" if event.starts_at > 3.months.from_now
    result << "event-rsvp"   if event.requires_rsvp
    result << "event-draft"  if event.draft?
    result << "event-cancelled" if event.cancelled?

    result.join(" ")
  end

  # TODO: shouldn't this whole thing just move to EventPolicy?
  # can a given member cancel a given event?
  # Three things have to be true:
  # (a) event is persisted,
  # (b) event isn't in a cancelled state already,
  # (c) member is authorized
  # TODO: should we also prevent past events from being cancelled?
  def event_cancellable?(event, member)
    !@event.new_record? &&
      @event.published? &&
      EventPolicy.new(event, member).cancel?
  end

  # TODO: shouldn't this whole thing just move to EventPolicy?
  # can a given member cancel a given event?
  # Three things have to be true: (a) event is persisted, (b) event is cancelled or draft, (c) member is authorized
  # TODO: should we also prevent past events from being cancelled?
  def event_deletable?(event, member)
    !@event.new_record? &&
      (@event.cancelled? || @event.draft?) &&
      EventPolicy.new(event, member).delete?
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
    parts = event.departs_from.present? ? ["dir", event.departs_from, event.destination] : ["search", event.destination]
    search_path = parts.map { |m| CGI.escape(m.gsub(",", "")) }.join("/")
    [MAP_BASE_URL, search_path].join
  end

  def location_address_string(event, prepend = "")
    res = [event.location, event.address].join(" ").strip
    res = "#{prepend}#{res}" if res.present?
    res
  end
end
