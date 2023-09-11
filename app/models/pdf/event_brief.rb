# frozen_string_literal: true

# a landscape view printable calendar with three columns (generally one column
# per month)
class Pdf::EventBrief < Prawn::Document
  MAX_COLUMN_COUNT = 3
  MAX_ROW_COUNT = 10
  GUTTER = 20
  MONTH_HEADER_HEIGHT = 2
  COLOR_TEXT_LIGHT = "888888"
  COLOR_BRAND = "E66425"
  PAGE_HEADER_HEIGHT = 50

  def initialize(event)
    super(page_layout: :landscape)
    @event = event
    @unit = @event.unit
    render_trip_brief
  end

  def filename
    "#{@unit.name} #{@event}.pdf"
  end

  def embed_fonts
    return

    font_families.update(
      "FontAwesome" => {
        normal: Rails.root.join("app/assets/webfonts/fa-solid-900.ttf")
      }
    )
  end

  def render_trip_brief
    embed_fonts
    define_grid(columns: 3, rows: 1, gutter: 20)
    @current_column = 0

    @presenter = EventPresenter.new
    @presenter.plain_text = true

    render_page_header

    grid(0, 0).bounding_box do
      move_down 10 + PAGE_HEADER_HEIGHT

      text @event.description.to_plain_text
      move_down 20

      stroke_horizontal_rule
      move_down 5
      formatted_text [
        { text: "Locations", size: 18, styles: [:bold] },
      ]
      move_down 10

      @event.locations.each do |location|
        formatted_text [
          { text: location.name, styles: [:bold] },
          { text: "\n" + location.address },
          { text: "\n" + location.phone },
          { text: "\n" + location.website }
        ]
        move_down 10
      end
    end
  end

  def render_page_header
    grid([0, 0], [0, MAX_COLUMN_COUNT - 1]).bounding_box do
      formatted_text [
        { text: "Trip Brief: #{@unit.name} #{@event.title}".upcase, size: 18, styles: [:bold], kerning: true }
      ]
      formatted_text [
        { text: "As of #{DateTime.now.in_time_zone(@unit.settings(:locale).time_zone).strftime('%B %-d, %Y')}".upcase,
          size: 10, styles: [:bold], kerning: true }
      ]
    end

    grid([0, 0], [0, MAX_COLUMN_COUNT - 1]).bounding_box do
      text("Generated by scoutplan.org", align: :right, size: 8, color: COLOR_TEXT_LIGHT)
    end
  end
end