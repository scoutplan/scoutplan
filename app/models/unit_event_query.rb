class UnitEventQuery
  attr_accessor :search_term
  attr_accessor :start_date

  def initialize(unit)
    @unit = unit
    @start_date = Date.today
  end

  def execute
    scope = @unit.events
    scope = scope.where(['starts_at >= ?', @start_date]) if @start_date.present?
    scope = scope.includes(:event_category, [event_rsvps: :user])
    scope.all
  end
end
