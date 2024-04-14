class Pdf::EventOrganizerPackage
  attr_reader :event, :unit

  def initialize(event)
    @event = event
  end

  def filename
    "Event Package for #{event.title} as of #{DateTime.now.in_time_zone(unit.settings(:locale).time_zone).strftime('%d %B %Y')}.pdf"
  end

  # rubocop:disable Metrics/AbcSize
  def render
    pdf = CombinePDF.parse(Pdf::EventRoster.new(event).render)
    event.attachments.each { |document| pdf << CombinePDF.parse(document.download) }
    event.private_attachments.each { |document| pdf << CombinePDF.parse(document.download) }
    pdf.to_pdf
  end
  # rubocop:enable Metrics/AbcSize
end
