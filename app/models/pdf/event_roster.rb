class Pdf::EventRoster < Prawn::Document
  attr_reader :event, :unit

  def initialize(event)
    super(page_layout: :portrait)
    @event = event
    @unit = event.unit
    @current_row = 1
    render_header
    define_grid(columns: 7, rows: 35, gutter: 10)
    render_roster
  end

  def filename
    "Event Roster for #{event.title} as of #{DateTime.now.in_time_zone(unit.settings(:locale).time_zone).strftime('%d %B %Y')}.pdf"
  end

  private

  def render_header
    formatted_text [
      { text: "#{unit.name} Roster".upcase,
        size: 10, styles: [:bold], kerning: true }
    ]
  end

  def render_roster
    move_down 20
    event.rsvps.joins(unit_membership: :user).order("users.last_name, users.first_name").each do |rsvp|
      render_rsvp(rsvp)
    end
  end

  def render_rsvp(rsvp)
    grid(@current_row, 0).bounding_box do
      formatted_text [
        { text: rsvp.user.last_name,
          size: 10, kerning: true }
      ]
    end
    grid(@current_row, 1).bounding_box do
      formatted_text [
        { text: rsvp.user.first_name,
          size: 10, kerning: true }
      ]
    end
    grid(@current_row, 2).bounding_box do
      formatted_text [
        { text: rsvp.member.member_type.capitalize,
          size: 10, kerning: true }
      ]
    end
    @current_row += 1
  end
end
