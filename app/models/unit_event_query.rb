class UnitEventQuery
  attr_accessor :search_term

  def initialize(unit)
    @unit = unit
  end

  def execute
    @unit.events.includes(:event_category, [event_rsvps: :user])
  end
end
