# frozen_string_literal: true

class CalendarPrintRenderer
  attr_accessor :unit, :events

  def initialize(unit, events)
    @unit = unit
    @events = events
  end

  def generate_pdf
    pdf = Prawn::Document.new(
      page_layout: :landscape
    )
    pdf.start_new_page
    # pdf.define_grid(columns: 3, rows: 1, gutter: 10)
    pdf.text "hi"
    pdf.render_file filename
  end

  def filename
    "#{@unit.name} Schedule as of #{Date.today.strftime('%-d %B %Y')}"
  end    
end