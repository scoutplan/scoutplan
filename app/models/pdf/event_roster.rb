class Pdf::EventRoster < Prawn::Document
  attr_reader :event, :unit

  def initialize(event)
    super(page_layout: :portrait)
    @event = event
    @unit = @event.unit
    @current_row = 3
    render_header
    define_grid(columns: 6, rows: 35, gutter: 10)
    render_roster
  end

  def filename
    "Event Roster for #{event.title} as of #{DateTime.now.in_time_zone(unit.settings(:locale).time_zone).strftime('%d %B %Y')}.pdf"
  end

  private

  def render_header
    items = [
      unit.name_and_location,
      event.title,
      event.location,
      event.date_to_s(plain_text: true, format: :short)
    ].compact

    items.each do |item|
      formatted_text [{ text: item, size: 10, styles: [:bold], kerning: true }]
    end
  end

  def render_roster
    column_headers = "   Last Name", "First Name", "Member Type"
    column_headers.each_with_index do |header, index|
      grid(@current_row - 1, index).bounding_box do
        formatted_text [{ text: header, size: 10, styles: [:bold], kerning: true }]
      end
    end
    event.rsvps.accepted.joins(unit_membership: :user).order("users.last_name, users.first_name").each do |rsvp|
      render_rsvp(rsvp)
    end
  end

  def render_rsvp(rsvp)
    items = [
      rsvp.user.last_name,
      rsvp.user.first_name,
      rsvp.member.member_type.capitalize
    ]

    items.each_with_index do |item, index|
      grid(@current_row, index).bounding_box do
        formatted_text [{ text: item, size: 10, kerning: true }]
      end
    end

    @current_row += 1
  end
end
