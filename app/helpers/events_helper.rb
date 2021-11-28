# frozen_string_literal: true

# helpers for Event views
module EventsHelper
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
end
